import AppKit
import Foundation
import ImageIO
import MascotAnimation
import Testing

@MainActor
@Test func atlasRowsMatchTheirFrozenFrameFiles() throws {
    let repositoryRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    let animationRoot = repositoryRoot.appending(path: "art/animation")
    let contractData = try Data(contentsOf: animationRoot.appending(path: "atlas-contract.json"))
    let contract = try JSONDecoder().decode(AtlasContract.self, from: contractData)
    let atlas = try SpriteAtlas(
        imageURL: animationRoot.appending(path: "mascot-atlas@2x.png"),
        contract: contract
    )

    for state in ["offline", "idle", "working", "ideating", "walk-right", "walk-left", "sit-shake-right", "sit-shake-left", "hanging", "hand-sign"] {
        let atlasFrame = try atlas.frame(state: state, index: 0)
        let frozenFrameURL = animationRoot
            .appending(path: "frames")
            .appending(path: state)
            .appending(path: "\(state)-00.png")
        let frozenFrame = try loadImage(at: frozenFrameURL)
        #expect(try rgbaPixels(of: atlasFrame.cgImage(forProposedRect: nil, context: nil, hints: nil)!) == rgbaPixels(of: frozenFrame))
    }
}

private func loadImage(at url: URL) throws -> CGImage {
    let source = try #require(CGImageSourceCreateWithURL(url as CFURL, nil))
    return try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
}

private func rgbaPixels(of image: CGImage) throws -> Data {
    var pixels = Data(count: image.width * image.height * 4)
    var didRender = false
    pixels.withUnsafeMutableBytes { bytes in
        guard let context = CGContext(
            data: bytes.baseAddress,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: image.width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        didRender = true
    }
    try #require(didRender)
    return pixels
}
