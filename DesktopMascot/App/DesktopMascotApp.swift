import AppKit

/// AppKit owns the entry point; there is no SwiftUI `App` or `Scene`.
///
/// This was a SwiftUI `App` until 2026-08-03. Its only scene was a
/// `MenuBarExtra`, which obeys the visibility macOS remembers for it — so once
/// the icon had been dragged off the menu bar, Control Center re-sent the hide
/// on every launch, SwiftUI was left with no scene, and it terminated the
/// process about a tenth of a second in. The app could not be launched,
/// controlled, or quit, and wrote no crash report.
///
/// The AppKit entry point is kept because it removes the `Settings`-scene
/// placeholder an `App` would otherwise need, not because it fixed the missing
/// icon. It was changed while chasing that bug and made no difference to it:
/// the icon's absence is keyed to the bundle identifier, not to the host. See
/// `AppDelegate.statusItem` for the evidence. An earlier version of this
/// comment blamed SwiftUI's scene machinery; that was wrong.
///
/// SwiftUI is still used for the menu's contents via `NSHostingMenu`, and for
/// the mascot views — only the entry point is AppKit.
@main
enum DockPetMain {
    static func main() {
        let application = NSApplication.shared
        // Held for the process lifetime: `NSApplication.delegate` is weak, and
        // a delegate that deallocates here takes the menu bar item with it.
        let delegate = AppDelegate()
        application.delegate = delegate
        application.run()
        withExtendedLifetime(delegate) {}
    }
}
