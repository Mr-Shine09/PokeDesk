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

            // Sits with its own mascot's Summon entry rather than in the
            // app-wide block below, because it belongs to one pet. Owner
            // decision, 2026-08-11, after finding that stopping one stopped
            // both. Named for the mode it switches *on* and checked when
            // roaming is off: it read "Roam Along Bottom" until the owner asked
            // for a stay-in-place option that had existed all along, which is
            // what a menu item named after what unchecking it does costs.
            let stationary = !appDelegate.isRoaming(mascot.provider)
            Button {
                appDelegate.setRoaming(stationary, for: mascot.provider)
            } label: {
                Label(
                    "\(mascot.displayName) Stays in One Place",
                    systemImage: stationary ? "checkmark" : "minus"
                )
            }
            .accessibilityLabel(
                stationary
                    ? "Let the \(mascot.displayName) mascot roam along the bottom of the screen again"
                    : "Keep the \(mascot.displayName) mascot in one place instead of roaming"
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

        // Sits with Manual Ideating because it answers the same question — is
        // the user thinking — from a weaker signal. The label names what is
        // watched (the app being in front), not a vague "chat detection", so
        // the privacy cost is legible from the menu itself.
        Button {
            appDelegate.setChatAppsDriveIdeating(!appDelegate.chatAppsDriveIdeating)
        } label: {
            Label(
                "Think When Chat App Is Open",
                systemImage: appDelegate.chatAppsDriveIdeating ? "checkmark" : "minus"
            )
        }
        .accessibilityLabel(
            appDelegate.chatAppsDriveIdeating
                ? "Stop the mascot thinking when the Claude or ChatGPT app is in front"
                : "Let the mascot think when the Claude or ChatGPT app is in front"
        )

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

        Text("Click for options • Drag anytime")
        Button("Reposition on Current Display") {
            appDelegate.reposition()
        }

        // The nightly window in which a quiet mascot sleeps instead of
        // strolling. Two 24-item submenus rather than a preset list, because a
        // preset list is a guess about which schedules matter and this costs
        // nothing extra to make complete.
        Menu(appDelegate.sleepScheduleSummary) {
            Button {
                appDelegate.setSleepWindow(nil)
            } label: {
                Label(
                    "Off — never sleep",
                    systemImage: appDelegate.sleepWindow == nil ? "checkmark" : "minus"
                )
            }
            .accessibilityLabel("Turn off scheduled sleep so the mascot never sleeps")
            Divider()
            Menu("Sleeps At") {
                ForEach(0 ..< 24, id: \.self) { hour in
                    Button {
                        appDelegate.setSleepStartHour(hour)
                    } label: {
                        Label(
                            AppDelegate.hourLabel(hour),
                            systemImage: appDelegate.sleepWindow?.startHour == hour
                                ? "checkmark"
                                : "minus"
                        )
                    }
                    .accessibilityLabel("Sleep from \(AppDelegate.hourLabel(hour))")
                }
            }
            Menu("Wakes At") {
                ForEach(0 ..< 24, id: \.self) { hour in
                    Button {
                        appDelegate.setSleepEndHour(hour)
                    } label: {
                        Label(
                            AppDelegate.hourLabel(hour),
                            systemImage: appDelegate.sleepWindow?.endHour == hour
                                ? "checkmark"
                                : "minus"
                        )
                    }
                    .accessibilityLabel("Wake at \(AppDelegate.hourLabel(hour))")
                }
            }
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

        // Temporary, and deliberately not a polished feature. It exists to
        // answer whether the Claude app exposes a usable "generating" signal at
        // all, before any lifecycle detection is built on the assumption that it
        // does. Remove this submenu once that question is settled either way.
        Menu("Chat Detection (Experimental)") {
            Text(appDelegate.accessibilityStatus)
            Button("Request Accessibility Access…") {
                appDelegate.requestAccessibilityAccess()
            }
            Button("Write Chat App Report to Desktop") {
                appDelegate.writeChatAccessibilityReport()
            }
        }

        Divider()

        Button("Quit Dock Pet") {
            appDelegate.quit()
        }
        .keyboardShortcut("q")
    }
}
