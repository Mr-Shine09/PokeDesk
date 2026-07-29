import CoreGraphics
import Foundation

public enum DockEdge: String, Equatable, Sendable {
    case bottom
    case left
    case right
}

public struct DockGeometry: Sendable {
    public static func inferDockEdge(frame: CGRect, visibleFrame: CGRect, threshold: CGFloat = 2) -> DockEdge {
        let candidates: [(DockEdge, CGFloat)] = [
            (.bottom, max(0, visibleFrame.minY - frame.minY)),
            (.left, max(0, visibleFrame.minX - frame.minX)),
            (.right, max(0, frame.maxX - visibleFrame.maxX)),
        ]
        guard let largest = candidates.max(by: { $0.1 < $1.1 }), largest.1 >= threshold else {
            return .bottom
        }
        return largest.0
    }

    public static func panelOrigin(
        screenFrame: CGRect,
        visibleFrame: CGRect,
        panelSize: CGSize,
        safetyGap: CGFloat = 8
    ) -> CGPoint {
        let edge = inferDockEdge(frame: screenFrame, visibleFrame: visibleFrame)
        let proposed: CGPoint
        switch edge {
        case .bottom:
            proposed = CGPoint(
                x: visibleFrame.midX - panelSize.width / 2,
                y: visibleFrame.minY + safetyGap
            )
        case .left:
            proposed = CGPoint(
                x: visibleFrame.minX + safetyGap,
                y: visibleFrame.midY - panelSize.height / 2
            )
        case .right:
            proposed = CGPoint(
                x: visibleFrame.maxX - panelSize.width - safetyGap,
                y: visibleFrame.midY - panelSize.height / 2
            )
        }
        return CGPoint(
            x: min(max(proposed.x, visibleFrame.minX), visibleFrame.maxX - panelSize.width),
            y: min(max(proposed.y, visibleFrame.minY), visibleFrame.maxY - panelSize.height)
        )
    }
}
