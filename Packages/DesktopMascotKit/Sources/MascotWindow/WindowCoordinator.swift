import AppKit

@MainActor
public final class WindowCoordinator: NSObject {
    public let panel: MascotPanel
    private let contentSize: NSSize
    private var relockTimer: Timer?

    public init(contentView: NSView, contentSize: NSSize = NSSize(width: 48, height: 56)) {
        self.contentSize = contentSize
        panel = MascotPanel(contentView: contentView, contentSize: contentSize)
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        reposition()
    }

    public func setVisible(_ visible: Bool) {
        if visible {
            reposition()
            panel.orderFrontRegardless()
        } else {
            panel.orderOut(nil)
        }
    }

    public func setInteractionUnlocked(_ unlocked: Bool, timeout: TimeInterval = 15) {
        relockTimer?.invalidate()
        panel.ignoresMouseEvents = !unlocked
        panel.isMovableByWindowBackground = unlocked
        guard unlocked else { return }
        relockTimer = Timer.scheduledTimer(
            timeInterval: timeout,
            target: self,
            selector: #selector(relockFromTimer),
            userInfo: nil,
            repeats: false
        )
    }

    public func reposition(on screen: NSScreen? = NSScreen.main) {
        guard let screen else { return }
        let origin = DockGeometry.panelOrigin(
            screenFrame: screen.frame,
            visibleFrame: screen.visibleFrame,
            panelSize: contentSize
        )
        panel.setFrameOrigin(origin)
    }

    @objc private func screenParametersChanged() {
        reposition()
    }

    @objc private func relockFromTimer() {
        setInteractionUnlocked(false)
    }
}
