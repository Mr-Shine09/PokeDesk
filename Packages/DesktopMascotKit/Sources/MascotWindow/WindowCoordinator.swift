import AppKit

@MainActor
public final class WindowCoordinator: NSObject {
    public let panel: MascotPanel
    private let contentSize: NSSize
    /// Shifts this mascot's *default* placement along the lane.
    ///
    /// Owner decision, 2026-08-01: with one mascot per provider, two panels can
    /// be summoned at once and would otherwise both land on the same default
    /// origin, appearing stacked. Each mascot gets its own offset so they
    /// arrive side by side. This affects the default position only — once
    /// roaming or dragging moves a panel the two are fully independent and may
    /// cross, which is intended.
    private let laneOffset: CGFloat
    /// The height the user last dropped the mascot at, or `nil` while it is
    /// still on the default bottom lane.
    private var manualLaneY: CGFloat?

    public init(
        contentView: NSView,
        contentSize: NSSize = MascotPanel.defaultContentSize,
        laneOffset: CGFloat = 0
    ) {
        self.contentSize = contentSize
        self.laneOffset = laneOffset
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

    /// `repositioning` defaults to `true` for the common case (launch, Show
    /// with no prior manual placement). Pass `false` to preserve wherever the
    /// user last dragged the panel — otherwise every Hide/Show or reopen
    /// would silently discard a manual position by snapping back to the
    /// default lane.
    public func setVisible(_ visible: Bool, repositioning: Bool = true) {
        if visible {
            if repositioning { reposition() }
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

    /// Whether the user has dropped the mascot at a height of their own.
    ///
    /// Read by callers that would otherwise reposition on Hide/Show, so a
    /// deliberate placement survives being dismissed and summoned again.
    public var hasManualPlacement: Bool { manualLaneY != nil }

    public func verticalPlacementBounds() -> ClosedRange<CGFloat>? {
        guard let screen = panel.screen ?? NSScreen.main else { return nil }
        let minimum = screen.frame.minY - MascotPanel.defaultDockVisualInset
        let maximum = max(minimum, screen.visibleFrame.maxY - contentSize.height)
        return minimum ... maximum
    }

    /// Adopts wherever the user dropped the mascot as its new roaming height.
    ///
    /// Owner decision, 2026-07-30: the pet roams from wherever it is dropped,
    /// rather than falling back to the bottom lane. The walk cycle only moves
    /// along X, so this makes the mascot walk left and right at the height it
    /// was released — including through open air above the Dock, which the owner
    /// asked for explicitly after seeing the lane-snapping version. The bottom
    /// lane remains the *default* placement and the destination of the
    /// Reposition menu action; it is no longer the only legal height.
    ///
    /// Both axes are clamped to the screen, because a pet dropped past an edge
    /// would otherwise roam somewhere it cannot be seen or grabbed back.
    public func settleAfterDrop() {
        let x = horizontalMovementBounds().map {
            min(max(panel.frame.minX, $0.lowerBound), $0.upperBound)
        } ?? panel.frame.minX
        let y = verticalPlacementBounds().map {
            min(max(panel.frame.minY, $0.lowerBound), $0.upperBound)
        } ?? panel.frame.minY
        manualLaneY = y
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    /// Returns the mascot to the default bottom lane, discarding a dropped
    /// height. This is what the Reposition menu action is for: once the pet can
    /// roam at any height, the user needs one deliberate way to get it back.
    public func reposition(on screen: NSScreen? = nil) {
        let screen = screen ?? panel.screen ?? NSScreen.main
        guard let screen else { return }
        manualLaneY = nil
        let origin = DockGeometry.panelOrigin(
            screenFrame: screen.frame,
            visibleFrame: screen.visibleFrame,
            panelSize: contentSize,
            visualInset: MascotPanel.defaultDockVisualInset
        )
        // Clamped, so an offset mascot on a narrow display still lands on
        // screen rather than being pushed off the right edge.
        let x = horizontalMovementBounds().map {
            min(max(origin.x + laneOffset, $0.lowerBound), $0.upperBound)
        } ?? origin.x
        panel.setFrameOrigin(NSPoint(x: x, y: origin.y))
    }

    /// A display change must not silently discard a dropped height, but it can
    /// leave one stranded off the new screen, so the placement is re-clamped
    /// rather than reset.
    @objc private func screenParametersChanged() {
        guard manualLaneY != nil else {
            reposition()
            return
        }
        settleAfterDrop()
    }

}
