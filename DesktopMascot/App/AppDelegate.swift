import AppKit
import Combine
import MascotAnimation
import MascotCore
import MascotWindow
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published private(set) var diagnostics = "Starting"
    @Published var isVisible = true
    @Published var isPaused = false
    @Published var isIdeating = false
    @Published var isRoaming = true

    /// Listens for provider lifecycle events, reduces them, and is the single
    /// source of the mascot's visible state — manual pause and ideating included,
    /// since those reach the reducer as overrides.
    let eventBridge = AgentEventBridge()

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
            windowCoordinator.panel.onDragEnded = { [weak self] in
                self?.animationController?.userDidEndDrag()
                self?.isRoaming = false
                self?.diagnostics = "Manual position — click mascot to resume roaming"
            }
            animationController = try AmbientAnimationController(
                atlas: atlas,
                previewModel: previewModel,
                windowCoordinator: windowCoordinator
            )
            animationController?.onSummonCompleted = { [weak self] in
                self?.refreshDiagnostics()
            }
            // The reduced state drives animation from here on. Nothing else may
            // select a row, so manual pause and ideating go through the reducer's
            // overrides rather than around it.
            visibleStateObserver = eventBridge.$visibleState
                .sink { [weak self] visibleState in
                    self?.animationController?.setVisibleState(visibleState.state)
                    self?.refreshDiagnostics()
                }
            setVisible(isVisible)
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
        isVisible = visible
        // Roaming off means the user dragged the mascot to a manual spot;
        // Hide/Show and reopen must not snap it back to the default lane.
        windowCoordinator?.setVisible(visible, repositioning: isRoaming)
        animationController?.setVisible(visible)
        diagnostics = visible ? "Opening Dock portal" : "Mascot hidden"
        if !visible { refreshDiagnostics() }
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

    /// Publishing the overrides is what changes the animation: the reducer folds
    /// them into `MascotVisibleState`, which the observer above feeds to the
    /// controller. Setting a row directly from here would reintroduce the second
    /// source of truth this wiring exists to remove.
    private func syncOverrides() {
        eventBridge.overrides = ManualOverrides(isPaused: isPaused, isIdeating: isIdeating)
        refreshDiagnostics()
    }

    func setRoaming(_ roaming: Bool) {
        isRoaming = roaming
        animationController?.setRoaming(roaming)
        refreshDiagnostics()
    }

    /// Describes what the pet is actually doing, without implying that a state
    /// with no provider behind it came from an agent.
    private func refreshDiagnostics() {
        guard isVisible else {
            diagnostics = "Mascot hidden"
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

    func quit() {
        NSApp.terminate(nil)
    }

    private func showMascotMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: isPaused ? "Resume Animation" : "Pause Animation", action: #selector(togglePauseFromMascot), keyEquivalent: "")
        menu.addItem(withTitle: isRoaming ? "Stop Roaming" : "Resume Roaming", action: #selector(toggleRoamingFromMascot), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Hide Mascot", action: #selector(hideMascotFromMenu), keyEquivalent: "")
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
