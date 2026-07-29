import AppKit

@MainActor
public final class MascotPanel: NSPanel {
    public static let defaultContentSize = NSSize(width: 96, height: 112)
    public static let defaultDockVisualInset: CGFloat = 10
    /// Matches the hanging row's fixed grip at atlas pixel (48, 4) in the 96x112-point panel.
    public static let hangingCursorAttachment = NSPoint(x: 48, y: 108)

    public var onClick: (() -> Void)?
    public var onDragBegan: (() -> Void)?
    public var onDragEnded: (() -> Void)?
    private var dragStartMouseLocation: NSPoint?
    private var dragStartWindowOrigin: NSPoint?
    private var didDrag = false

    public init(contentView: NSView, contentSize: NSSize) {
        super.init(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        self.contentView = contentView
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        ignoresMouseEvents = false
        isMovableByWindowBackground = false
        animationBehavior = .none
    }

    public override var canBecomeKey: Bool { false }
    public override var canBecomeMain: Bool { false }

    public override func sendEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            beginPointerInteraction(with: event)
        case .leftMouseDragged:
            continuePointerInteraction(with: event)
        case .leftMouseUp:
            endPointerInteraction()
        case .rightMouseDown:
            onClick?()
        default:
            super.sendEvent(event)
        }
    }

    private func beginPointerInteraction(with event: NSEvent) {
        dragStartMouseLocation = convertPoint(toScreen: event.locationInWindow)
        dragStartWindowOrigin = frame.origin
        didDrag = false
    }

    private func continuePointerInteraction(with event: NSEvent) {
        guard let mouseStart = dragStartMouseLocation, let windowStart = dragStartWindowOrigin else { return }
        let current = convertPoint(toScreen: event.locationInWindow)
        let delta = NSPoint(x: current.x - mouseStart.x, y: current.y - mouseStart.y)
        if abs(delta.x) >= 3 || abs(delta.y) >= 3 {
            if !didDrag {
                onDragBegan?()
            }
            didDrag = true
        }
        if didDrag {
            setFrameOrigin(NSPoint(
                x: current.x - Self.hangingCursorAttachment.x,
                y: current.y - Self.hangingCursorAttachment.y
            ))
        } else {
            setFrameOrigin(NSPoint(x: windowStart.x + delta.x, y: windowStart.y + delta.y))
        }
    }

    private func endPointerInteraction() {
        if didDrag {
            onDragEnded?()
        } else {
            onClick?()
        }
        dragStartMouseLocation = nil
        dragStartWindowOrigin = nil
        didDrag = false
    }
}
