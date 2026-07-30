import SwiftUI

struct MenuBarContent: View {
    @ObservedObject var appDelegate: AppDelegate
    @ObservedObject var eventBridge: AgentEventBridge

    var body: some View {
        // Named for the action rather than a state toggle: the mascot is summoned
        // deliberately, and the app never puts one on screen by itself.
        Button {
            appDelegate.setVisible(!appDelegate.isVisible)
        } label: {
            Label(
                appDelegate.isVisible ? "Dismiss Mascot" : "Summon Mascot",
                systemImage: appDelegate.isVisible ? "arrow.down.left.circle" : "sparkles"
            )
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
            appDelegate.setRoaming(!appDelegate.isRoaming)
        } label: {
            Label("Roam Along Bottom", systemImage: appDelegate.isRoaming ? "checkmark" : "minus")
        }
        Text("Click for options • Drag anytime")
        Button("Reposition on Current Display") {
            appDelegate.reposition()
        }
        Divider()
        Text(appDelegate.diagnostics)
        Text(eventBridge.summary)
        Text(eventBridge.reducedStateSummary)
        Text(EventHelperLocation.summary)
        Button("Copy Event Helper Path") {
            appDelegate.copyHelperPath()
        }
        .disabled(EventHelperLocation.path == nil)
        Button("Quit Dock Pet") {
            appDelegate.quit()
        }
        .keyboardShortcut("q")
    }
}
