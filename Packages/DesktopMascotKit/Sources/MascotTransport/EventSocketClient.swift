import Darwin
import Foundation
import MascotCore

public enum EventSocketClientError: Error, Equatable, Sendable {
    case socketPathTooLong
    case socketCreationFailed(code: Int32)
    /// Nothing is listening, or the socket file is gone. Expected whenever Dock
    /// Pet is not running, and never worth failing a provider hook over.
    case notListening(code: Int32)
    case writeFailed(code: Int32)
    case frameTooLarge(bytes: Int, limit: Int)
}

/// Writes exactly one event frame and closes.
///
/// One-shot on purpose: a provider hook is a short-lived process, so there is no
/// connection to keep, retry, or queue.
public struct EventSocketClient: Sendable {
    public let socketURL: URL
    public let maximumFrameBytes: Int

    public init(
        socketURL: URL,
        maximumFrameBytes: Int = EventDecoderLimits().maximumPayloadBytes
    ) {
        self.socketURL = socketURL
        self.maximumFrameBytes = maximumFrameBytes
    }

    public func send(_ envelope: EventEnvelope) throws {
        let frame = EventEncoder().encodeFrame(envelope)
        guard frame.count <= maximumFrameBytes else {
            throw EventSocketClientError.frameTooLarge(bytes: frame.count, limit: maximumFrameBytes)
        }
        try send(frame: frame)
    }

    /// The raw primitive, deliberately not public: only the envelope path is a
    /// supported way in. Tests use it to prove the server survives bytes no
    /// legitimate client would send.
    func send(frame: Data) throws {
        guard let address = UnixSocketAddress(path: socketURL.path) else {
            throw EventSocketClientError.socketPathTooLong
        }

        let descriptor = socket(AF_UNIX, SOCK_STREAM, 0)
        guard descriptor >= 0 else {
            throw EventSocketClientError.socketCreationFailed(code: errno)
        }
        defer { close(descriptor) }

        let connected = address.withSockAddr { pointer, length in
            connect(descriptor, pointer, length)
        }
        guard connected == 0 else {
            throw EventSocketClientError.notListening(code: errno)
        }

        try frame.withUnsafeBytes { buffer in
            var offset = 0
            while offset < buffer.count {
                let written = write(descriptor, buffer.baseAddress!.advanced(by: offset), buffer.count - offset)
                if written > 0 {
                    offset += written
                    continue
                }
                if written < 0 && (errno == EINTR || errno == EAGAIN) { continue }
                throw EventSocketClientError.writeFailed(code: errno)
            }
        }
    }
}
