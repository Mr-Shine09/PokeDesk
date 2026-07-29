import AppKit
import MascotWindow
import SwiftUI

@MainActor
final class MascotPreviewModel: ObservableObject {
    @Published var image: NSImage?
}

struct MascotPreviewView: View {
    @ObservedObject var model: MascotPreviewModel

    var body: some View {
        Group {
            if let image = model.image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
            } else {
                Color.clear
            }
        }
        .frame(
            width: MascotPanel.defaultContentSize.width,
            height: MascotPanel.defaultContentSize.height
        )
        .background(Color.clear)
        .accessibilityHidden(true)
    }
}
