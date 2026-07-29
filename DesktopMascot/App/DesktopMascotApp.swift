import SwiftUI

@main
struct DesktopMascotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Dock Pet", systemImage: "pawprint.fill") {
            MenuBarContent(appDelegate: appDelegate)
        }
        .menuBarExtraStyle(.menu)
    }
}
