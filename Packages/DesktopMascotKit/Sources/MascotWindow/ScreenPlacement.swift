import CoreGraphics
import Foundation

/// Chooses which display a panel belongs to, from the panel's own geometry.
///
/// `NSScreen.main` is deliberately not consulted anywhere in this module. It
/// names the display holding the window that currently receives key events,
/// which has nothing to do with where the mascot is. With a second display
/// attached that made placement follow keyboard focus: a mascot dropped past an
/// edge — where it overlaps no display and `NSWindow.screen` is `nil` — was
/// clamped against whichever display happened to have focus, so the same drop
/// landed in two different places depending on where the user had last clicked.
/// It could also clamp the mascot onto a display it had never been dragged to,
/// which the ledger's placement rules already forbid ("never teleport across
/// unrelated displays unless the user selects a display", 2026-07-28).
///
/// Everything here is pure `CGRect` arithmetic so multi-display placement can
/// be tested against synthetic arrangements instead of whatever hardware
/// happens to be plugged into the machine running the suite.
public struct ScreenPlacement: Sendable {
    /// The index in `screenFrames` of the display a panel at `panelFrame`
    /// should be placed against, or `nil` when there are no displays.
    ///
    /// The rules, in order:
    ///
    /// 1. The display the panel covers most of. This matches what AppKit's own
    ///    `NSWindow.screen` reports for a panel that is on screen, so an
    ///    ordinary drag onto a second display keeps behaving as it looks.
    /// 2. When the panel overlaps no display at all — dropped past an outer
    ///    edge, or stranded in a gap or dead corner of an uneven arrangement —
    ///    the nearest display, measured from the panel's centre. That pulls the
    ///    mascot back to the display it left rather than to an unrelated one.
    /// 3. Ties go to the lowest index, so a panel exactly between two displays
    ///    resolves the same way every time rather than by call order.
    public static func screenIndex(forPanelFrame panelFrame: CGRect, in screenFrames: [CGRect]) -> Int? {
        guard !screenFrames.isEmpty else { return nil }

        var best: (index: Int, overlap: CGFloat)?
        for (index, frame) in screenFrames.enumerated() {
            let intersection = frame.intersection(panelFrame)
            guard !intersection.isNull else { continue }
            let overlap = intersection.width * intersection.height
            // A zero-area intersection is two displays touching along a shared
            // edge, not the panel being on one of them.
            guard overlap > 0 else { continue }
            if best == nil || overlap > best!.overlap {
                best = (index, overlap)
            }
        }
        if let best { return best.index }

        let centre = CGPoint(x: panelFrame.midX, y: panelFrame.midY)
        var nearest: (index: Int, distance: CGFloat)?
        for (index, frame) in screenFrames.enumerated() {
            let closest = CGPoint(
                x: min(max(centre.x, frame.minX), frame.maxX),
                y: min(max(centre.y, frame.minY), frame.maxY)
            )
            let dx = centre.x - closest.x
            let dy = centre.y - closest.y
            // Squared distance: the ordering is the same and it avoids a
            // square root whose rounding could flip a near-tie.
            let distance = dx * dx + dy * dy
            if nearest == nil || distance < nearest!.distance {
                nearest = (index, distance)
            }
        }
        return nearest?.index
    }
}
