import Darwin
import Dispatch
import Foundation
import MascotCore

/// Why a connection or frame was refused. No case carries payload text.
public enum EventRejection: Equatable, Sendable {
    /// The peer's effective UID is not this process's UID, or could not be read.
    case differentUser
    case oversizedFrame(bytes: Int)
    case decoding(EventDecodingError)
}

public enum EventSocketServerError: Error, Equatable, Sendable {
    case socketPathTooLong
    case directoryUnavailable(code: Int32)
    case socketCreationFailed(code: Int32)
    case addressInUse
    case bindFailed(code: Int32)
    case listenFailed(code: Int32)
    case alreadyRunning
}

/// A local-only `AF_UNIX` listener that turns bytes into validated envelopes.
///
/// There is no network path: the socket family is `AF_UNIX`, so this cannot
/// listen on or reach a network interface even if misconfigured.
///
/// `@unchecked Sendable` is deliberate. Every mutable property is touched only
/// from `queue`, a serial dispatch queue, and the two callbacks are `@Sendable`.
public final class EventSocketServer: @unchecked Sendable {
    public struct Configuration: Sendable {
        public var socketURL: URL
        public var decoderLimits: EventDecoderLimits
        public var backlog: Int32
        /// Bound on simultaneous helper connections, so a runaway hook loop
        /// cannot exhaust the app's file descriptors.
        public var maximumConnections: Int

        public init(
            socketURL: URL,
            decoderLimits: EventDecoderLimits = EventDecoderLimits(),
            backlog: Int32 = 16,
            maximumConnections: Int = 8
        ) {
            self.socketURL = socketURL
            self.decoderLimits = decoderLimits
            self.backlog = backlog
            self.maximumConnections = maximumConnections
        }
    }

    private final class Connection {
        let descriptor: Int32
        var reader: EventFrameReader
        var source: DispatchSourceRead?

        init(descriptor: Int32, reader: EventFrameReader) {
            self.descriptor = descriptor
            self.reader = reader
        }
    }

    private let configuration: Configuration
    private let decoder: EventDecoder
    private let now: @Sendable () -> Date
    private let onEvent: @Sendable (EventEnvelope) -> Void
    private let onRejection: @Sendable (EventRejection) -> Void
    private let queue = DispatchQueue(label: "com.mrshine09.desktopmascot.event-socket")

    private var listenerDescriptor: Int32 = -1
    private var listenerSource: DispatchSourceRead?
    private var connections: [Int32: Connection] = [:]

    public init(
        configuration: Configuration,
        now: @escaping @Sendable () -> Date = Date.init,
        onEvent: @escaping @Sendable (EventEnvelope) -> Void,
        onRejection: @escaping @Sendable (EventRejection) -> Void = { _ in }
    ) {
        self.configuration = configuration
        self.decoder = EventDecoder(limits: configuration.decoderLimits)
        self.now = now
        self.onEvent = onEvent
        self.onRejection = onRejection
    }

    deinit {
        stop()
    }

    public func start() throws {
        try queue.sync {
            guard listenerDescriptor < 0 else { throw EventSocketServerError.alreadyRunning }

            let path = configuration.socketURL.path
            guard let address = UnixSocketAddress(path: path) else {
                throw EventSocketServerError.socketPathTooLong
            }
            try prepareDirectory()

            let descriptor = socket(AF_UNIX, SOCK_STREAM, 0)
            guard descriptor >= 0 else {
                throw EventSocketServerError.socketCreationFailed(code: errno)
            }

            // A socket file left behind by a crash would make `bind` fail with
            // EADDRINUSE forever, so a dead one is removed first. A *live* one
            // means another Dock Pet is already listening and must not be stolen.
            if access(path, F_OK) == 0 {
                guard !Self.isSocketAlive(at: address) else {
                    close(descriptor)
                    throw EventSocketServerError.addressInUse
                }
                unlink(path)
            }

            let bound = address.withSockAddr { pointer, length in
                bind(descriptor, pointer, length)
            }
            guard bound == 0 else {
                let code = errno
                close(descriptor)
                throw EventSocketServerError.bindFailed(code: code)
            }
            // Narrow the mode after bind: `bind` applies the process umask, which
            // this process does not control.
            chmod(path, mode_t(EventSocketLocation.socketPermissions))

            guard listen(descriptor, configuration.backlog) == 0 else {
                let code = errno
                close(descriptor)
                unlink(path)
                throw EventSocketServerError.listenFailed(code: code)
            }

            // The accept handler drains every pending connection in a loop, so the
            // listener must not block once the queue is empty — a blocking accept
            // here would wedge this serial queue permanently.
            Self.makeNonBlocking(descriptor)

            listenerDescriptor = descriptor
            let source = DispatchSource.makeReadSource(fileDescriptor: descriptor, queue: queue)
            source.setEventHandler { [weak self] in self?.acceptPendingConnections() }
            // Dispatch requires the descriptor to outlive the source, so only the
            // cancel handler ever closes it.
            source.setCancelHandler { close(descriptor) }
            listenerSource = source
            source.resume()
        }
    }

    /// Idempotent. Every descriptor is closed by its source's cancel handler, so
    /// nothing here closes one directly and no descriptor is closed twice.
    public func stop() {
        queue.sync {
            for connection in connections.values {
                connection.source?.cancel()
            }
            connections.removeAll()

            guard listenerDescriptor >= 0 else { return }
            listenerSource?.cancel()
            listenerSource = nil
            listenerDescriptor = -1
            unlink(configuration.socketURL.path)
        }
    }

    /// Test and diagnostic hook. Never used to make transport decisions.
    public var isListening: Bool {
        queue.sync { listenerDescriptor >= 0 }
    }

    // MARK: - Directory

    private func prepareDirectory() throws {
        let directory = configuration.socketURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true,
                attributes: [.posixPermissions: NSNumber(value: EventSocketLocation.directoryPermissions)]
            )
        } catch {
            throw EventSocketServerError.directoryUnavailable(code: errno)
        }
        // `createDirectory` leaves an existing directory's mode alone, so tighten
        // it unconditionally rather than trusting whatever created it first.
        chmod(directory.path, mode_t(EventSocketLocation.directoryPermissions))
    }

    /// Distinguishes a stale socket file from a live listener by trying to
    /// connect to it. Only ever used before binding.
    private static func isSocketAlive(at address: UnixSocketAddress) -> Bool {
        let probe = socket(AF_UNIX, SOCK_STREAM, 0)
        guard probe >= 0 else { return false }
        defer { close(probe) }
        return address.withSockAddr { pointer, length in
            connect(probe, pointer, length) == 0
        }
    }

    // MARK: - Accepting

    private func acceptPendingConnections() {
        while true {
            let descriptor = accept(listenerDescriptor, nil, nil)
            guard descriptor >= 0 else { return }

            guard Self.isSameUser(descriptor) else {
                close(descriptor)
                onRejection(.differentUser)
                continue
            }
            guard connections.count < configuration.maximumConnections else {
                close(descriptor)
                continue
            }

            Self.makeNonBlocking(descriptor)
            let connection = Connection(
                descriptor: descriptor,
                reader: EventFrameReader(maximumFrameBytes: configuration.decoderLimits.maximumPayloadBytes)
            )
            let source = DispatchSource.makeReadSource(fileDescriptor: descriptor, queue: queue)
            source.setEventHandler { [weak self] in self?.readAvailable(on: descriptor) }
            source.setCancelHandler { close(descriptor) }
            connection.source = source
            connections[descriptor] = connection
            source.resume()
        }
    }

    /// The same-user guarantee. File permissions already exclude other accounts,
    /// but this verifies the peer's identity rather than inferring it from the
    /// filesystem, so a mode changed out from under us cannot widen access.
    private static func makeNonBlocking(_ descriptor: Int32) {
        let flags = fcntl(descriptor, F_GETFL, 0)
        guard flags >= 0 else { return }
        _ = fcntl(descriptor, F_SETFL, flags | O_NONBLOCK)
    }

    private static func isSameUser(_ descriptor: Int32) -> Bool {
        var euid: uid_t = 0
        var egid: gid_t = 0
        guard getpeereid(descriptor, &euid, &egid) == 0 else { return false }
        return euid == getuid()
    }

    // MARK: - Reading

    private func readAvailable(on descriptor: Int32) {
        guard let connection = connections[descriptor] else { return }

        var chunk = [UInt8](repeating: 0, count: 4_096)
        let count = read(descriptor, &chunk, chunk.count)

        guard count > 0 else {
            // 0 is a clean peer close; negative is an error. Either way the
            // helper is one-shot, so the connection is finished.
            if count < 0 && (errno == EAGAIN || errno == EINTR) { return }
            closeConnection(descriptor)
            return
        }

        for output in connection.reader.append(Data(chunk[0 ..< count])) {
            switch output {
            case .discardedOversizedFrame(let bytes):
                onRejection(.oversizedFrame(bytes: bytes))
            case .frame(let frame):
                do {
                    onEvent(try decoder.decode(frame, now: now()))
                } catch let error as EventDecodingError {
                    // One bad frame is dropped; the connection and every other
                    // frame on it stay valid. Malformed data cannot change state.
                    onRejection(.decoding(error))
                } catch {
                    onRejection(.decoding(.malformedJSON))
                }
            }
        }
    }

    private func closeConnection(_ descriptor: Int32) {
        guard let connection = connections.removeValue(forKey: descriptor) else { return }
        connection.source?.cancel()
    }
}
