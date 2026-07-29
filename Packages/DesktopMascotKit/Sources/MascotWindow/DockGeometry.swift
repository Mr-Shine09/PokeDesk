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
        safetyGap: CGFloat = 0,
        visualInset: CGFloat = 0
    ) -> CGPoint {
        let edge = inferDockEdge(frame: screenFrame, visibleFrame: visibleFrame)
        let proposed: CGPoint
        switch edge {
        case .bottom:
            proposed = CGPoint(
                x: visibleFrame.minX + visibleFrame.width / 3 - panelSize.width / 2,
                y: visibleFrame.minY - visualInset + safetyGap
            )
        case .left:
            proposed = CGPoint(
                x: visibleFrame.minX - visualInset + safetyGap,
                y: visibleFrame.midY - panelSize.height / 2
            )
        case .right:
            proposed = CGPoint(
                x: visibleFrame.maxX - panelSize.width + visualInset - safetyGap,
                y: visibleFrame.midY - panelSize.height / 2
            )
        }
        let horizontalBounds: (minimum: CGFloat, maximum: CGFloat)
        let verticalBounds: (minimum: CGFloat, maximum: CGFloat)
        switch edge {
        case .bottom:
            horizontalBounds = (visibleFrame.minX, visibleFrame.maxX - panelSize.width)
            verticalBounds = (screenFrame.minY, visibleFrame.maxY - panelSize.height)
        case .left:
            horizontalBounds = (screenFrame.minX, visibleFrame.maxX - panelSize.width)
            verticalBounds = (visibleFrame.minY, visibleFrame.maxY - panelSize.height)
        case .right:
            horizontalBounds = (visibleFrame.minX, screenFrame.maxX - panelSize.width)
            verticalBounds = (visibleFrame.minY, visibleFrame.maxY - panelSize.height)
        }
        return CGPoint(
            x: min(max(proposed.x, horizontalBounds.minimum), horizontalBounds.maximum),
            y: min(max(proposed.y, verticalBounds.minimum), verticalBounds.maximum)
        )
    }
}
