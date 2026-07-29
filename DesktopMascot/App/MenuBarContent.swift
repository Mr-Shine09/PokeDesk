import SwiftUI

struct MenuBarContent: View {
    @ObservedObject var appDelegate: AppDelegate

    var body: some View {
        Button {
            appDelegate.setVisible(!appDelegate.isVisible)
        } label: {
            Label("Show Mascot", systemImage: appDelegate.isVisible ? "checkmark" : "minus")
        }
        Button {
            appDelegate.setPaused(!appDelegate.isPaused)
        } label: {
            Label("Pause", systemImage: appDelegate.isPaused ? "checkmark" : "minus")
        }
        Button {
            appDelegate.setIdeating(!appDelegate.isIdeating)
        } label: {
            Label("Manual Ideating", systemImage: appDelegate.isIdeating ? "checkmark" : "minus")
        }
        Divider()
        Button {
            appDelegate.setPositionUnlocked(!appDelegate.isPositionUnlocked)
        } label: {
            Label("Unlock Position", systemImage: appDelegate.isPositionUnlocked ? "lock.open" : "lock")
        }
        Button("Reposition on Current Display") {
            appDelegate.reposition()
        }
        Divider()
        Text(appDelegate.diagnostics)
        Button("Quit Dock Pet") {
            appDelegate.quit()
        }
        .keyboardShortcut("q")
    }
}
