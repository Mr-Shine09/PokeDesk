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
    /// The last display the panel was genuinely on, used to pull it back after
    /// it is dropped somewhere no display covers.
    private var lastKnownScreen: NSScreen?

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

    /// The display this mascot's placement is measured against, resolved from
    /// the panel's own position rather than from keyboard focus.
    ///
    /// `NSWindow.screen` is nil whenever the window lies entirely outside every
    /// display — precisely what a drop past an edge produces. The fallback used
    /// to be `NSScreen.main`, which is *the screen with keyboard focus*, so with
    /// two displays attached the answer depended on where the user happened to
    /// be typing at that instant. A mascot dropped into dead space off the right
    /// of the built-in display could be clamped back onto the external one, and
    /// `aDropPastAnEdgeIsClampedBackIntoView` passed or failed run to run for the
    /// same reason. That flakiness was recorded as a deterministic
    /// second-display defect; it is really this nondeterminism, and the two have
    /// one cause.
    ///
    /// The replacement prefers the display the panel was last genuinely on, so
    /// throwing the pet off an edge returns it to the display it came from
    /// rather than moving it to another one, and falls back to the nearest
    /// display only when there is no history to use.
    private var referenceScreen: NSScreen? {
        if let screen = panel.screen {
            lastKnownScreen = screen
            return screen
        }
        let screens = NSScreen.screens
        guard !screens.isEmpty else { return NSScreen.main }
        // The display the mascot was last actually on wins. A drop past an edge
        // should pull it back onto the display it came from, not move it to a
        // different one — the user threw it off the edge, they did not ask for
        // it to change screens.
        if let remembered = lastKnownScreen, screens.contains(remembered) {
            return remembered
        }
        // No history — first placement, or the remembered display was
        // unplugged. Fall back to the display nearest the panel.
        let center = CGPoint(x: panel.frame.midX, y: panel.frame.midY)
        return screens.min {
            Self.squaredDistance(from: center, to: $0.frame)
                < Self.squaredDistance(from: center, to: $1.frame)
        }
    }

    /// Zero when the point is inside the rectangle, otherwise the squared
    /// distance to its nearest edge. Squared to avoid a pointless `sqrt` in a
    /// comparison.
    private static func squaredDistance(from point: CGPoint, to rect: CGRect) -> CGFloat {
        let dx = max(rect.minX - point.x, 0, point.x - rect.maxX)
        let dy = max(rect.minY - point.y, 0, point.y - rect.maxY)
        return dx * dx + dy * dy
    }

    public func horizontalMovementBounds() -> ClosedRange<CGFloat>? {
        guard let screen = referenceScreen else { return nil }
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
        guard let screen = referenceScreen else { return nil }
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
        let screen = screen ?? referenceScreen
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
    ///
    /// The height is re-clamped from `manualLaneY`, **not** from the panel's
    /// current frame. That distinction is the whole fix for a defect observed
    /// on 2026-08-10: unplugging the display a mascot was on returned it to the
    /// bottom of the surviving display, discarding a dragged height that fit
    /// there untouched. This handler used to call `settleAfterDrop()`, which
    /// derives the height from `panel.frame.minY` — right for a drop, where the
    /// frame *is* the user's intent, and wrong here, because AppKit has already
    /// relocated the window off the removed display by the time this runs, so
    /// the frame holds the system's intent instead. The remembered value was
    /// sitting unread the whole time. A resolution change preserved the height
    /// correctly, which is what identified relocation as the trigger: with no
    /// display removed the two values are identical and the bug is invisible.
    ///
    /// The horizontal position is still taken from the frame, deliberately.
    /// There is no remembered X to prefer — roaming rewrites it continuously —
    /// so wherever the window ended up is as good an answer as any.
    @objc private func screenParametersChanged() {
        guard let laneY = manualLaneY else {
            reposition()
            return
        }
        let x = horizontalMovementBounds().map {
            min(max(panel.frame.minX, $0.lowerBound), $0.upperBound)
        } ?? panel.frame.minX
        let y = verticalPlacementBounds().map {
            min(max(laneY, $0.lowerBound), $0.upperBound)
        } ?? laneY
        manualLaneY = y
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

}
