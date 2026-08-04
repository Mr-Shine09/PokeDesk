import SwiftUI

@main
struct DesktopMascotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // The menu bar item is built by `AppDelegate.installStatusItem()`, not
        // declared here as a `MenuBarExtra`. See `AppDelegate.statusItem` for
        // the reason: a `MenuBarExtra` obeys the visibility macOS remembers for
        // it, and once this item had been dragged off the menu bar the app
        // terminated itself on every launch because that scene was its only
        // one. An owned `NSStatusItem` keeps both the icon and the app alive.
        //
        // `Settings` is here because `App` requires a scene. It opens no window
        // in an `LSUIElement` accessory, and there are no settings to show —
        // every control lives in the menu.
        Settings { EmptyView() }
    }
}
