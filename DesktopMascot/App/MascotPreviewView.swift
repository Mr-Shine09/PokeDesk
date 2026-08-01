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
            if model.isDismissing, !model.usesReducedMotion {
                SmokeCloudView(
                    expansion: model.dismissFrame.smokeExpansion,
                    opacity: model.dismissFrame.smokeOpacity
                )
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

/// The dismiss smoke: overlapping soft puffs that burst outward and thin out.
///
/// Drawn in SwiftUI rather than as atlas art, following the summon portal. The
/// cloud has to be larger than the mascot and fade continuously, and the frozen
/// palette's binary alpha cannot express that.
private struct SmokeCloudView: View {
    let expansion: Double
    let opacity: Double

    /// Puff centres and radii in panel points. `y` is measured up from the
    /// bottom of the panel, where the mascot's feet are.
    ///
    /// The body runs from roughly `y = 9` at the shoes to `y = 87` at the hair,
    /// and the cloud has to cover all of it — an earlier layout clustered around
    /// the torso and left the legs and shoes sticking out below the smoke.
    private static let puffs: [(x: CGFloat, y: CGFloat, radius: CGFloat)] = [
        (0, 48, 30),
        (-22, 44, 22),
        (22, 46, 22),
        (-15, 70, 20),
        (16, 72, 21),
        (0, 86, 22),
        (-18, 24, 21),
        (19, 26, 21),
        (0, 10, 20),
        (10, 62, 14),
        (-11, 60, 13),
    ]

    var body: some View {
        ZStack {
            ForEach(Array(Self.puffs.enumerated()), id: \.offset) { index, puff in
                Circle()
                    .fill(index.isMultiple(of: 2) ? Color.white : Color(white: 0.78))
                    .frame(width: puff.radius * 2 * spread, height: puff.radius * 2 * spread)
                    .position(
                        x: MascotPanel.defaultContentSize.width / 2 + puff.x * drift,
                        y: MascotPanel.defaultContentSize.height - puff.y
                    )
                    .blur(radius: 3)
            }
        }
        .frame(
            width: MascotPanel.defaultContentSize.width,
            height: MascotPanel.defaultContentSize.height
        )
        .opacity(opacity)
        .allowsHitTesting(false)
    }

    /// The cloud arrives close to body-sized and then billows, rather than
    /// growing from nothing. A smoke bomb is instant, and starting small left
    /// the mascot clearly visible through a cloud too thin to hide it — the
    /// opacity ramp, not the size, is what makes the smoke appear.
    ///
    /// The top of the range stops short of where the cloud would be clipped hard
    /// by the panel edge, which reads as a rectangle of smoke rather than a cloud.
    private var spread: CGFloat { 0.7 + CGFloat(expansion) * 0.55 }

    /// The cloud also widens as it billows, so the puffs separate instead of
    /// staying a fixed rosette.
    private var drift: CGFloat { 0.75 + CGFloat(expansion) * 0.5 }
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
