import AppKit
import MascotAnimation
import MascotWindow
import SwiftUI

@MainActor
final class MascotPreviewModel: ObservableObject {
    @Published var image: NSImage?
    @Published var isSummoning = false
    @Published var summonFrame = PortalSummonFrame.resting
    @Published var isDismissing = false
    @Published var dismissFrame = PoofDismissFrame.resting
    /// The current `poof` cell, drawn over the mascot. Separate from `image`
    /// because the smoke is a layer on top of the character, not a pose of it.
    @Published var smokeImage: NSImage?
    @Published var usesReducedMotion = false
}

struct MascotPreviewView: View {
    @ObservedObject var model: MascotPreviewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            if model.isSummoning, !model.usesReducedMotion {
                PortalBackView(openness: model.summonFrame.portalOpenness)
                    .padding(.bottom, 2)
            }

            if let image = model.image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaleEffect(petScale, anchor: .bottom)
                    .offset(y: petOffset)
                    .opacity(petOpacity)
            } else {
                Color.clear
            }

            if model.isSummoning, !model.usesReducedMotion {
                PortalFrontView(openness: model.summonFrame.portalOpenness)
                    .padding(.bottom, 2)
            }

            // Last in the stack so the mascot vanishes behind it rather than in
            // front of it.
            if model.isDismissing, let smoke = model.smokeImage {
                Image(nsImage: smoke)
                    .resizable()
                    .interpolation(.none)
                    .opacity(model.dismissFrame.smokeOpacity)
                    .allowsHitTesting(false)
            }
        }
        .frame(
            width: MascotPanel.defaultContentSize.width,
            height: MascotPanel.defaultContentSize.height
        )
        .background(Color.clear)
        .clipped()
        .accessibilityHidden(true)
    }

    private var reveal: CGFloat {
        if model.isDismissing { return CGFloat(model.dismissFrame.petReveal) }
        if model.isSummoning { return CGFloat(model.summonFrame.petReveal) }
        return 1
    }

    /// The summon rises out of the Dock; the dismiss does not sink back into it,
    /// because the pet is meant to read as having vanished from where it stood.
    private var petOffset: CGFloat {
        guard !model.usesReducedMotion, !model.isDismissing else { return 0 }
        return (1 - reveal) * 72
    }

    private var petScale: CGFloat {
        model.usesReducedMotion ? 1 : 0.82 + reveal * 0.18
    }

    private var petOpacity: Double {
        Double(reveal)
    }
}

private struct PortalBackView: View {
    let openness: Double

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 0.16, green: 0.04, blue: 0.34).opacity(0.9))
                .shadow(color: Color.cyan.opacity(0.8), radius: 7)
            Ellipse()
                .stroke(Color(red: 0.55, green: 0.18, blue: 0.95), lineWidth: 5)
            Ellipse()
                .stroke(Color.cyan.opacity(0.95), lineWidth: 2)
        }
        .frame(width: 76 * CGFloat(openness), height: max(2, 15 * CGFloat(openness)))
        .opacity(openness)
    }
}

private struct PortalFrontView: View {
    let openness: Double

    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [.cyan, Color(red: 0.72, green: 0.28, blue: 1), .cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 70 * CGFloat(openness), height: max(1, 4 * CGFloat(openness)))
            .shadow(color: .cyan.opacity(0.9), radius: 3)
            .opacity(openness)
    }
}
