import Foundation

/// Where the app listens and the helper connects.
///
/// Both sides derive the same path from the current user's Application Support
/// directory, so no environment variable, command-line path, or configuration
/// file has to carry it — one less place for a caller to point the helper
/// somewhere unintended.
public enum EventSocketLocation {
    public static let directoryName = "com.mrshine09.desktopmascot"
    /// Kept short on purpose: the full path must fit `sun_path`.
    public static let socketName = "events.sock"

    /// Owner-only so no other local account can read or write the socket. The
    /// same-user peer check in `EventSocketServer` is the second layer, because
    /// permissions alone are a weaker promise than verified peer identity.
    public static let directoryPermissions: Int16 = 0o700
    public static let socketPermissions: Int16 = 0o600

    public static func directoryURL(fileManager: FileManager = .default) throws -> URL {
        try fileManager
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(directoryName, isDirectory: true)
    }

    public static func socketURL(fileManager: FileManager = .default) throws -> URL {
        try directoryURL(fileManager: fileManager).appendingPathComponent(socketName, isDirectory: false)
    }
}
