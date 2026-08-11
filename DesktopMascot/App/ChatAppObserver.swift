import AppKit
import Combine
import MascotCore

/// Watches which application is frontmost, and reports only whether it is one
/// of the two allowlisted chat apps.
///
/// This is the narrowest signal that answers "is the user thinking at a chat
/// app", and it is worth being explicit about what it is *not*. It reads no
/// window title, no document, no accessibility tree, no browser tab, and
/// nothing typed; it asks `NSWorkspace` for the frontmost application's bundle
/// identifier, which needs no permission and no entitlement, and it keeps the
/// answer only as `ChatPresence`. Every other app on the machine maps to `nil`
/// and is never named anywhere, including in diagnostics.
///
/// **Frontmost rather than running** on purpose: a chat app left open behind an
/// editor all day is not the user thinking, and treating it as such would leave
/// the pet permanently ideating for anyone who never quits apps.
@MainActor
final class ChatAppObserver: ObservableObject {
    /// The providers whose chat app is in front. Empty in the ordinary case.
    @Published private(set) var presence: ChatPresence = .none

    /// How long a chat app stays "in front" after losing focus.
    ///
    /// Without this, Command-Tab through a chat app, or clicking a notification,
    /// flickers the pet into the Thinker pose and straight back out. It is
    /// deliberately shorter than the 0.75 s selector dwell is long, so the two
    /// compose into one calm transition instead of a visible stutter.
    private static let lingerAfterDeactivation: TimeInterval = 2.0

    private var observer: (any NSObjectProtocol)?
    private var lingerTask: Task<Void, Never>?
    /// Set while `isEnabled` is false so re-enabling restores the real answer
    /// immediately rather than waiting for the next app switch.
    private var isEnabled: Bool

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.frontmostChanged() }
        }
        frontmostChanged()
    }

    // No `deinit` unregisters the observer or cancels the linger task,
    // deliberately, and for the same reason `AmbientAnimationController` has
    // none: `AppDelegate` builds exactly one of these at launch and holds it for
    // the process's lifetime, and a nonisolated `deinit` cannot touch either
    // property under Swift 6 isolation. If this ever becomes disposable, both
    // have to be torn down at that point.

    /// Turning this off must clear the presence, not merely stop updating it —
    /// otherwise the pet keeps ideating at whatever the last answer was, and the
    /// switch looks broken.
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        lingerTask?.cancel()
        lingerTask = nil
        if enabled {
            frontmostChanged()
        } else {
            presence = .none
        }
    }

    private func frontmostChanged() {
        guard isEnabled else { return }
        let identifier = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        guard let provider = ChatApp.provider(forBundleIdentifier: identifier) else {
            scheduleClear()
            return
        }
        lingerTask?.cancel()
        lingerTask = nil
        presence = ChatPresence(providers: [provider])
    }

    private func scheduleClear() {
        guard !presence.providers.isEmpty, lingerTask == nil else { return }
        lingerTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Self.lingerAfterDeactivation))
            guard !Task.isCancelled else { return }
            await MainActor.run { self?.clearIfStillAway() }
        }
    }

    /// Re-reads rather than clearing blindly: two seconds is long enough for the
    /// user to have switched from one chat app straight to the other, and
    /// clearing on a stale answer would blink the pose off and on.
    private func clearIfStillAway() {
        lingerTask = nil
        guard isEnabled else { return }
        let identifier = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        if let provider = ChatApp.provider(forBundleIdentifier: identifier) {
            presence = ChatPresence(providers: [provider])
        } else {
            presence = .none
        }
    }
}
