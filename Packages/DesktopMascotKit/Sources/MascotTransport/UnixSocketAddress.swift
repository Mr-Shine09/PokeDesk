import Foundation

/// A validated `AF_UNIX` address.
///
/// `sun_path` is a fixed 104-byte field on Darwin. A path that does not fit
/// cannot be silently truncated — truncation would bind a *different* socket
/// than intended — so an overlong path is rejected up front.
struct UnixSocketAddress {
    static let maximumPathLength = MemoryLayout.size(ofValue: sockaddr_un().sun_path) - 1

    let path: String
    private let bytes: [CChar]

    init?(path: String) {
        let encoded = Array(path.utf8CString)
        // `utf8CString` includes the terminator, so the payload is count - 1.
        guard encoded.count - 1 <= Self.maximumPathLength, encoded.count > 1 else { return nil }
        self.path = path
        self.bytes = encoded
    }

    /// Builds the address and hands it to `body` as a generic `sockaddr`, which
    /// is the shape `bind` and `connect` require.
    func withSockAddr<Result>(_ body: (UnsafePointer<sockaddr>, socklen_t) -> Result) -> Result {
        var address = sockaddr_un()
        address.sun_family = sa_family_t(AF_UNIX)
        withUnsafeMutablePointer(to: &address.sun_path) { field in
            let destination = UnsafeMutableRawPointer(field).assumingMemoryBound(to: CChar.self)
            for (offset, byte) in bytes.enumerated() {
                destination[offset] = byte
            }
        }
        address.sun_len = UInt8(MemoryLayout<sockaddr_un>.size)

        let length = socklen_t(MemoryLayout<sockaddr_un>.size)
        return withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { body($0, length) }
        }
    }
}
