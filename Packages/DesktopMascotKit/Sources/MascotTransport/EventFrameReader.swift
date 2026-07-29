import Foundation
import MascotCore

/// Splits a byte stream into newline-delimited frames with a hard size ceiling.
///
/// Deliberately free of any I/O so every hostile-input case — a frame split
/// across reads, a frame larger than the ceiling, a flood with no newline at
/// all — is a pure unit test rather than a socket test.
public struct EventFrameReader: Sendable {
    public enum Output: Equatable, Sendable {
        case frame(Data)
        /// The frame exceeded `maximumFrameBytes` and was dropped. The bytes are
        /// counted but never surfaced, because an oversized frame is untrusted
        /// input that may contain private content.
        case discardedOversizedFrame(bytes: Int)
    }

    public let maximumFrameBytes: Int

    private var buffer = Data()
    /// Set after an overlong frame: everything up to the next newline belongs to
    /// that frame and must be dropped rather than parsed as a new one.
    private var discarding = false
    private var discardedBytes = 0

    public init(maximumFrameBytes: Int = EventDecoderLimits().maximumPayloadBytes) {
        self.maximumFrameBytes = maximumFrameBytes
    }

    public mutating func append(_ data: Data) -> [Output] {
        buffer.append(data)
        var outputs: [Output] = []

        while true {
            if discarding {
                guard let newline = buffer.firstIndex(of: 0x0A) else {
                    discardedBytes += buffer.count
                    buffer.removeAll(keepingCapacity: true)
                    return outputs
                }
                discardedBytes += buffer.distance(from: buffer.startIndex, to: newline)
                buffer.removeSubrange(buffer.startIndex ... newline)
                outputs.append(.discardedOversizedFrame(bytes: discardedBytes))
                discarding = false
                discardedBytes = 0
                continue
            }

            guard let newline = buffer.firstIndex(of: 0x0A) else {
                // No terminator yet. A buffer already past the ceiling can never
                // become a valid frame, so stop accumulating immediately instead
                // of growing without bound.
                if buffer.count > maximumFrameBytes {
                    discarding = true
                    discardedBytes = 0
                    continue
                }
                return outputs
            }

            let frame = Self.trimmingCarriageReturn(buffer[buffer.startIndex ..< newline])
            buffer.removeSubrange(buffer.startIndex ... newline)

            if frame.count > maximumFrameBytes {
                outputs.append(.discardedOversizedFrame(bytes: frame.count))
            } else if !frame.isEmpty {
                // An empty line is a no-op keepalive, not a malformed frame.
                outputs.append(.frame(Data(frame)))
            }
        }
    }

    private static func trimmingCarriageReturn(_ slice: Data.SubSequence) -> Data.SubSequence {
        guard slice.last == 0x0D else { return slice }
        return slice.dropLast()
    }
}
