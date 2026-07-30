import CoreGraphics
import Foundation

/// Places the panel along the bottom of the screen's visible frame.
///
/// The Dock's edge is deliberately not tracked: a user can move the Dock to
/// any side at any time, but a screen's bottom edge cannot move, so anchoring
/// there is what stays correct without reacting to Dock changes. An earlier
/// edge-aware version positioned the panel correctly for a left/right Dock
/// but did not carry that edge into roaming bounds, so the mascot could walk
/// horizontally across the middle of the screen. Left/right Dock placement is
/// deferred to a future release rather than fixed in place.
public struct DockGeometry: Sendable {
    public static func panelOrigin(
        screenFrame: CGRect,
        visibleFrame: CGRect,
        panelSize: CGSize,
        safetyGap: CGFloat = 0,
        visualInset: CGFloat = 0
    ) -> CGPoint {
        let proposed = CGPoint(
            x: visibleFrame.minX + visibleFrame.width / 3 - panelSize.width / 2,
            y: visibleFrame.minY - visualInset + safetyGap
        )
        // `max(minimum, ...)` guards a visible frame narrower or shorter than
        // the panel: without it, the upper bound could fall below the lower
        // bound and `min(max(x, lower), upper)` would clamp to the wrong end.
        let horizontalBounds = (
            minimum: visibleFrame.minX,
            maximum: max(visibleFrame.minX, visibleFrame.maxX - panelSize.width)
        )
        let verticalBounds = (
            minimum: screenFrame.minY,
            maximum: max(screenFrame.minY, visibleFrame.maxY - panelSize.height)
        )
        return CGPoint(
            x: min(max(proposed.x, horizontalBounds.minimum), horizontalBounds.maximum),
            y: min(max(proposed.y, verticalBounds.minimum), verticalBounds.maximum)
        )
    }
}
