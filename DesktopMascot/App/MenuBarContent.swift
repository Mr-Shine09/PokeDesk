import MascotCore
import MascotTransport
import SwiftUI

/// The control surface that works whether or not the mascot is on screen.
///
/// Status lines carry explicit accessibility labels because the compact text a
/// sighted user scans (`3 accepted • 1 session`) reads as noise aloud. The
/// spoken form says what the numbers mean.
struct MenuBarContent: View {
    @ObservedObject var appDelegate: AppDelegate
    @ObservedObject var eventBridge: AgentEventBridge

    var body: some View {
        // One toggle per mascot. Owner decision, 2026-08-01: presence is
        // manual and independent, so running both agents means summoning both
        // pets deliberately rather than having the app decide. Named for the
        // action rather than a state toggle — the app never puts one on screen
        // by itself.
        ForEach(appDelegate.mascots, id: \.provider) { mascot in
            let isOn = appDelegate.summoned.contains(mascot.provider)
            Button {
                appDelegate.setVisible(!isOn, for: mascot.provider)
            } label: {
                Label(
                    isOn ? "Dismiss \(mascot.displayName)" : "Summon \(mascot.displayName)",
                    systemImage: isOn ? "arrow.down.left.circle" : "sparkles"
                )
            }
            .accessibilityLabel(
                isOn
                    ? "Dismiss the \(mascot.displayName) mascot"
                    : "Summon the \(mascot.displayName) mascot to the screen"
            )
        }

        Button {
            appDelegate.setPaused(!appDelegate.isPaused)
        } label: {
            Label("Pause", systemImage: appDelegate.isPaused ? "checkmark" : "minus")
        }
        .accessibilityLabel(appDelegate.isPaused ? "Resume animation" : "Pause animation")

        Button {
            appDelegate.setIdeating(!appDelegate.isIdeating)
        } label: {
            Label("Manual Ideating", systemImage: appDelegate.isIdeating ? "checkmark" : "minus")
        }

        Button {
            appDelegate.setMuted(!appDelegate.isMuted)
        } label: {
            Label("Sounds", systemImage: appDelegate.isMuted ? "minus" : "checkmark")
        }
        .accessibilityLabel(
            appDelegate.isMuted
                ? "Turn on the mascot sounds"
                : "Silence the mascot sounds"
        )

        Divider()

        Button {
            appDelegate.setRoaming(!appDelegate.isRoaming)
        } label: {
            Label("Roam Along Bottom", systemImage: appDelegate.isRoaming ? "checkmark" : "minus")
        }
        .accessibilityLabel(
            appDelegate.isRoaming
                ? "Stop the mascot roaming along the bottom of the screen"
                : "Let the mascot roam along the bottom of the screen"
        )
        Text("Click for options • Drag anytime")
        Button("Reposition on Current Display") {
            appDelegate.reposition()
        }

        // Every animation reachable without an agent, which is otherwise
        // impossible for the states only a real session can produce.
        Menu("Preview State") {
            Button {
                appDelegate.setPreview(nil)
            } label: {
                Label(
                    "Off — follow real activity",
                    systemImage: appDelegate.previewState == nil ? "checkmark" : "minus"
                )
            }
            Divider()
            ForEach(MascotState.allCases, id: \.self) { state in
                Button {
                    appDelegate.setPreview(state)
                } label: {
                    Label(
                        state.displayName,
                        systemImage: appDelegate.previewState == state ? "checkmark" : "minus"
                    )
                }
                .accessibilityLabel("Preview the \(state.displayName) animation")
            }
        }

        Divider()

        Text(appDelegate.diagnostics)
            .accessibilityLabel("Mascot status: \(appDelegate.diagnostics)")
        Text(eventBridge.summary)
            .accessibilityLabel(eventBridge.spokenSummary)
        Text(eventBridge.reducedStateSummary)

        // Setup is copy-only: Dock Pet shows what to add and never edits the
        // file that runs the user's real agent.
        Menu("Agent Hook Setup") {
            Text(EventHelperLocation.summary)
            Button("Copy Claude Code Setup") {
                appDelegate.copyHookSetup(for: .claudeCode)
            }
            .disabled(EventHelperLocation.path == nil)
            Button("Copy Codex Setup") {
                appDelegate.copyHookSetup(for: .codex)
            }
            .disabled(EventHelperLocation.path == nil)
            Divider()
            Button("Copy Helper Path Only") {
                appDelegate.copyHelperPath()
            }
            .disabled(EventHelperLocation.path == nil)
        }

        Divider()

        Button("Quit Dock Pet") {
            appDelegate.quit()
        }
        .keyboardShortcut("q")
    }
}
