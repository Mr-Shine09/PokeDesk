import Foundation

/// Where the bundled `dockpet-event` helper lives, for a provider hook to invoke.
///
/// A hook is a short-lived process started by Claude Code or Codex, not by Dock
/// Pet, so it cannot discover the helper on its own — it needs an absolute path
/// written into its configuration. This resolves that path from the running
/// bundle rather than hard-coding one, because the app has no install location
/// yet and today's path is a DerivedData path that changes on rebuild.
enum EventHelperLocation {
    static let executableName = "dockpet-event"

    /// `nil` when the helper is missing from the bundle, which means the build
    /// dropped the copy phase rather than that the helper failed somehow.
    static var url: URL? {
        guard let url = Bundle.main.url(forAuxiliaryExecutable: executableName) else {
            return nil
        }
        return FileManager.default.isExecutableFile(atPath: url.path) ? url : nil
    }

    static var path: String? { url?.path }

    /// One line for the menu bar. Deliberately says the path is not durable:
    /// until the app is installed somewhere permanent, a hook configured with
    /// today's path will silently stop finding the helper after a rebuild.
    static var summary: String {
        url == nil
            ? "Event helper: missing from this build"
            : "Event helper: bundled (path changes on rebuild)"
    }
}
