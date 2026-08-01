import AppKit
import Combine
import MascotAnimation
import MascotCore
import MascotTransport
import MascotWindow
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published private(set) var diagnostics = "Starting"
    /// The mascot starts hidden and appears only when summoned.
    ///
    /// Owner decision, 2026-07-30: launching the app must not put a pet on the
    /// screen. The app is a menu-bar accessory first, and the mascot is
    /// something the user calls for — so launch leaves the menu-bar item ready
    /// and nothing else. There is deliberately no launch-at-login either.
    @Published var isVisible = false
    @Published var isPaused = false
    @Published var isIdeating = false
    /// Restored from preferences, so a deliberate choice survives relaunch.
    @Published var isRoaming = Preferences.roaming
    /// Forces one animation for inspection. Never persisted: it is a testing
    /// mode, and finding the pet stuck in a fake state after a relaunch with no
    /// memory of choosing it would be its own bug.
    @Published private(set) var previewState: MascotState?

    /// Listens for provider lifecycle events, reduces them, and is the single
    /// source of the mascot's visible state — manual pause and ideating included,
    /// since those reach the reducer as overrides.
    let eventBridge = AgentEventBridge()

    /// Mirrors the player's own persisted setting so the menu can bind to it.
    @Published var isMuted = Preferences.soundsMuted

    private let sounds = MascotSoundPlayer()
    /// Set once Quit has been asked for, so the transition cannot be cancelled
    /// by a summon and the app cannot be left running after asking to stop.
    private var isQuitting = false
    private let previewModel = MascotPreviewModel()
    private var atlas: SpriteAtlas?
    private var windowCoordinator: WindowCoordinator?
    private var animationController: AmbientAnimationController?
    private var visibleStateObserver: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        // Started before the mascot loads so a resource failure below still
        // leaves the event path diagnosable from the menu bar.
        eventBridge.start()
        do {
            let resources = try AppResources.load()
            let contractData = try Data(contentsOf: resources.contractURL)
            let contract = try JSONDecoder().decode(AtlasContract.self, from: contractData)
            let atlas = try SpriteAtlas(imageURL: resources.atlasURL, contract: contract)
            self.atlas = atlas
            previewModel.image = try atlas.frame(state: "idle", index: 0)

            let hostingView = NSHostingView(rootView: MascotPreviewView(model: previewModel))
            hostingView.frame = NSRect(origin: .zero, size: MascotPanel.defaultContentSize)
            let windowCoordinator = WindowCoordinator(contentView: hostingView)
            self.windowCoordinator = windowCoordinator
            windowCoordinator.panel.onClick = { [weak self] in
                self?.showMascotMenu()
            }
            windowCoordinator.panel.onDragBegan = { [weak self] in
                self?.animationController?.userDidBeginDrag()
                self?.diagnostics = "Dragging — hanging pose"
            }
            // A drop no longer switches roaming off. Dragging places the mascot;
            // whether it walks afterwards stays the user's separate choice, made
            // in the menu. See `userDidEndDrag()` for why.
            windowCoordinator.panel.onDragEnded = { [weak self] in
                self?.animationController?.userDidEndDrag()
                self?.refreshDiagnostics()
            }
            animationController = try AmbientAnimationController(
                atlas: atlas,
                previewModel: previewModel,
                windowCoordinator: windowCoordinator
            )
            animationController?.onSummonCompleted = { [weak self] in
                self?.refreshDiagnostics()
            }
            // The two transition cues. Both accompany something the user asked
            // for and can see, so neither needs the visibility gate the
            // reaction cues have.
            animationController?.onSummonStarted = { [weak self] in
                self?.sounds.play(.summon)
            }
            animationController?.onDismissBurst = { [weak self] in
                self?.sounds.play(.dismiss)
            }
            // Gated on visibility: a dismissed mascot is one the user chose not
            // to have on screen, and a chime from an invisible pet is a sound
            // with nothing to explain it.
            animationController?.onStateAppeared = { [weak self] state in
                guard let self, self.isVisible else { return }
                self.sounds.stateDidAppear(state)
            }
            // The reduced state drives animation from here on. Nothing else may
            // select a row, so manual pause and ideating go through the reducer's
            // overrides rather than around it.
            visibleStateObserver = eventBridge.$visibleState
                .sink { [weak self] visibleState in
                    self?.animationController?.setVisibleState(visibleState.state)
                    self?.refreshDiagnostics()
                }
            // Deliberately not `setVisible(true)`: launching is not summoning.
            // This orders the panel out and leaves the animation timer stopped,
            // so an unsummoned Dock Pet costs nothing but the menu-bar item.
            setVisible(false)
        } catch {
            diagnostics = error.localizedDescription
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Removes the socket file, so the next launch does not have to decide
        // whether a leftover one belongs to a live instance.
        eventBridge.stop()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        setVisible(true)
        diagnostics = "Mascot reopened"
        return true
    }

    func setVisible(_ visible: Bool) {
        // Quit is already under way and is not negotiable. Without this, a
        // reopen event arriving during the farewell would cancel the dismiss,
        // and the completion that terminates the app would never fire.
        guard !isQuitting else { return }
        isVisible = visible

        if visible {
            // A dropped height is a deliberate placement, so Hide/Show and
            // reopen must preserve it. Roaming no longer signals this: dragging
            // leaves roaming on, so the coordinator's own record of the drop is
            // the only reliable answer to "did the user place this themselves?".
            let placed = windowCoordinator?.hasManualPlacement ?? false
            windowCoordinator?.setVisible(true, repositioning: !placed)
            animationController?.setVisible(true)
            diagnostics = "Opening Dock portal"
            return
        }

        // The pet leaves the way it arrived, through a transition rather than by
        // blinking out: it forms a ninja hand seal and vanishes in a smoke poof.
        // The panel therefore stays on screen until the animation says it is
        // finished, so hiding is deferred into the completion below. `isVisible`
        // flips immediately regardless, so the menu never offers to dismiss a
        // mascot that is already leaving.
        guard let animationController, animationController.isVisible else {
            completeHiding()
            return
        }
        diagnostics = "Dismissing — hand sign and smoke poof"
        animationController.beginDismiss { [weak self] in
            self?.completeHiding()
        }
    }

    private func completeHiding() {
        windowCoordinator?.setVisible(false)
        animationController?.setVisible(false)
        refreshDiagnostics()
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
        if paused { isIdeating = false }
        syncOverrides()
    }

    func setIdeating(_ ideating: Bool) {
        isIdeating = ideating
        if ideating { isPaused = false }
        syncOverrides()
    }

    /// Shows one state for inspection, so every animation is reachable without an
    /// agent. Passing `nil` returns to whatever the reducer actually believes.
    ///
    /// Mutually exclusive with pause and ideating, because the reducer places a
    /// preview above both and leaving them set would strand the user in a state
    /// they cannot see the effect of.
    func setPreview(_ state: MascotState?) {
        previewState = state
        if state != nil {
            isPaused = false
            isIdeating = false
        }
        syncOverrides()
    }

    /// Publishing the overrides is what changes the animation: the reducer folds
    /// them into `MascotVisibleState`, which the observer above feeds to the
    /// controller. Setting a row directly from here would reintroduce the second
    /// source of truth this wiring exists to remove.
    private func syncOverrides() {
        eventBridge.overrides = ManualOverrides(
            isPaused: isPaused,
            isIdeating: isIdeating,
            preview: previewState
        )
        refreshDiagnostics()
    }

    func setMuted(_ muted: Bool) {
        isMuted = muted
        sounds.isMuted = muted
    }

    func setRoaming(_ roaming: Bool) {
        isRoaming = roaming
        animationController?.setRoaming(roaming)
        Preferences.roaming = roaming
        refreshDiagnostics()
    }

    /// Describes what the pet is actually doing, without implying that a state
    /// with no provider behind it came from an agent.
    private func refreshDiagnostics() {
        guard isVisible else {
            // Says what to do about it, since this is now the state the app
            // launches in rather than an unusual one.
            diagnostics = "Not summoned — choose Summon Mascot"
            return
        }
        // Named as a preview so a forced state is never mistaken for a real one.
        if let previewState {
            diagnostics = "Previewing \(previewState.displayName) — not a real agent state"
            return
        }
        let state = eventBridge.visibleState
        let providers = state.providers.map(\.rawValue).joined(separator: ", ")
        switch state.state {
        case .paused:
            diagnostics = "Animation paused"
        case .ideating:
            diagnostics = "Manual ideating"
        case .offline:
            diagnostics = isRoaming
                ? "Ambient roaming — no agent signal connected"
                : "Resting at manual position — no agent signal connected"
        case .idle:
            diagnostics = "Strolling — \(providers) idle"
        case .working, .waiting, .success, .failure, .sleeping:
            diagnostics = "\(state.state.displayName) — \(providers)"
        }
    }

    func reposition() {
        windowCoordinator?.reposition()
    }

    /// Puts the bundled helper's absolute path on the clipboard, so it can be
    /// pasted into a provider hook configuration. Copying is the whole action:
    /// Dock Pet does not edit anyone's hook files.
    func copyHelperPath() {
        guard let path = EventHelperLocation.path else {
            diagnostics = "Event helper is missing from this build"
            return
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(path, forType: .string)
        diagnostics = "Helper path copied"
    }

    /// Copies the exact hook configuration for a provider, so the user can read
    /// every line before it goes anywhere near their settings file.
    ///
    /// Dock Pet never writes that file. Issue #10 asks for verify/disable/
    /// uninstall actions per provider; those would all mean editing the file
    /// that runs the user's actual agent, and a mascot getting that wrong breaks
    /// the tool they work in. Preview-and-paste is the deliberate substitute.
    func copyHookSetup(for provider: EventProvider) {
        guard let path = EventHelperLocation.path else {
            diagnostics = "Event helper is missing from this build"
            return
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(
            HookConfiguration.instructions(for: provider, helperPath: path),
            forType: .string
        )
        diagnostics = "\(provider.rawValue) hook setup copied"
    }

    /// Quitting says goodbye first, when there is a mascot on screen to say it.
    ///
    /// Owner request, 2026-08-01: the same seal and poof that plays for Dismiss.
    /// It costs about a second, so the escape hatches matter more than the
    /// animation does — a second Quit terminates immediately, and an
    /// unsummoned mascot skips the farewell entirely rather than making the
    /// user watch a transition for a pet that was never there.
    func quit() {
        guard
            !isQuitting,
            let animationController,
            animationController.isVisible
        else {
            NSApp.terminate(nil)
            return
        }
        isQuitting = true
        isVisible = false
        diagnostics = "Quitting — hand sign and smoke poof"
        animationController.beginDismiss { [weak self] in
            self?.completeHiding()
            NSApp.terminate(nil)
        }
    }

    private func showMascotMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: isPaused ? "Resume Animation" : "Pause Animation", action: #selector(togglePauseFromMascot), keyEquivalent: "")
        menu.addItem(withTitle: isRoaming ? "Stop Roaming" : "Resume Roaming", action: #selector(toggleRoamingFromMascot), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Dismiss Mascot", action: #selector(hideMascotFromMenu), keyEquivalent: "")
        menu.addItem(withTitle: "Quit Dock Pet", action: #selector(quitFromMascotMenu), keyEquivalent: "")
        for item in menu.items { item.target = self }
        guard let contentView = windowCoordinator?.panel.contentView else { return }
        menu.popUp(positioning: nil, at: NSPoint(x: contentView.bounds.midX, y: contentView.bounds.midY), in: contentView)
    }

    @objc private func togglePauseFromMascot() { setPaused(!isPaused) }
    @objc private func toggleRoamingFromMascot() { setRoaming(!isRoaming) }
    @objc private func hideMascotFromMenu() { setVisible(false) }
    @objc private func quitFromMascotMenu() { quit() }
}
