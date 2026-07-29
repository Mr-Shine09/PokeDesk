import AppKit

@MainActor
public final class WindowCoordinator: NSObject {
    public let panel: MascotPanel
    private let contentSize: NSSize

    public init(contentView: NSView, contentSize: NSSize = MascotPanel.defaultContentSize) {
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

    public func horizontalMovementBounds() -> ClosedRange<CGFloat>? {
        guard let screen = panel.screen ?? NSScreen.main else { return nil }
        let minimum = screen.visibleFrame.minX
        let maximum = max(minimum, screen.visibleFrame.maxX - contentSize.width)
        return minimum ... maximum
    }

    public func setHorizontalPosition(_ x: CGFloat) {
        guard let bounds = horizontalMovementBounds() else { return }
        panel.setFrameOrigin(NSPoint(x: min(max(x, bounds.lowerBound), bounds.upperBound), y: panel.frame.minY))
    }

    public func reposition(on screen: NSScreen? = nil) {
        let screen = screen ?? panel.screen ?? NSScreen.main
        guard let screen else { return }
        let origin = DockGeometry.panelOrigin(
            screenFrame: screen.frame,
            visibleFrame: screen.visibleFrame,
            panelSize: contentSize,
            visualInset: MascotPanel.defaultDockVisualInset
        )
        panel.setFrameOrigin(origin)
    }

    @objc private func screenParametersChanged() {
        reposition()
    }

}
