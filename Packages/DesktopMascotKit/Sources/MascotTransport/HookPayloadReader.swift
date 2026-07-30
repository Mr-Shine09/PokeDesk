import Dispatch
import Foundation

/// Reads a hook payload from a file handle, completely but never indefinitely.
///
/// Two failure modes make the obvious implementations wrong:
///
/// - `availableData` returns the *first* chunk, not the whole payload. A large
///   `tool_input` arrives in pieces, and parsing the first piece yields
///   truncated JSON that silently maps to nothing — a bug that would look like
///   "the mascot just doesn't react sometimes".
/// - `readDataToEndOfFile` waits for EOF, which never comes if the writer keeps
///   the pipe open. A hook runs inside the user's real agent session, so waiting
///   forever is the single worst thing this helper could do.
///
/// So: read to EOF on a background queue, and abandon the whole attempt if it
/// takes longer than the deadline. Silence is always an acceptable outcome here.
public enum HookPayloadReader {
    /// Chosen well under the 5-second timeout the generated hook configuration
    /// sets, so the helper gives up before the provider has to kill it.
    public static let defaultDeadline: TimeInterval = 2

    private final class Box: @unchecked Sendable {
        private let lock = NSLock()
        private var storage: Data?
        func set(_ value: Data?) { lock.withLock { storage = value } }
        var value: Data? { lock.withLock { storage } }
    }

    /// `nil` when the payload was oversized, or did not arrive in time. The
    /// reading thread may still be blocked when this returns; that is deliberate
    /// and harmless, because the process exits immediately afterwards.
    public static func read(
        from handle: FileHandle,
        byteLimit: Int = HookPayload.maximumPayloadBytes,
        deadline: TimeInterval = defaultDeadline
    ) -> Data? {
        let box = Box()
        let finished = DispatchSemaphore(value: 0)

        DispatchQueue.global(qos: .userInitiated).async {
            var accumulated = Data()
            while true {
                let chunk = handle.availableData
                if chunk.isEmpty { break }
                accumulated.append(chunk)
                guard accumulated.count <= byteLimit else {
                    box.set(nil)
                    finished.signal()
                    return
                }
            }
            box.set(accumulated)
            finished.signal()
        }

        guard finished.wait(timeout: .now() + deadline) == .success else { return nil }
        return box.value
    }
}
