import AppKit
import Foundation
import ImageIO

public enum SpriteAtlasError: Error, LocalizedError {
    case unreadableImage
    case invalidContract
    case unknownState(String)
    case frameOutOfRange(state: String, index: Int)
    case cropFailed

    public var errorDescription: String? {
        switch self {
        case .unreadableImage: "The sprite atlas image could not be decoded."
        case .invalidContract: "The sprite atlas contract has invalid geometry."
        case let .unknownState(state): "The sprite atlas has no row named \(state)."
        case let .frameOutOfRange(state, index): "Frame \(index) is outside the \(state) row."
        case .cropFailed: "The requested atlas frame could not be cropped."
        }
    }
}

@MainActor
public final class SpriteAtlas {
    public let contract: AtlasContract
    private let image: CGImage

    public init(imageURL: URL, contract: AtlasContract) throws {
        guard
            let source = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            throw SpriteAtlasError.unreadableImage
        }
        guard
            contract.atlas.pixelSize.count == 2,
            contract.atlas.cellPixelSize.count == 2,
            contract.atlas.cellPointSize.count == 2,
            image.width == contract.atlas.pixelSize[0],
            image.height == contract.atlas.pixelSize[1]
        else {
            throw SpriteAtlasError.invalidContract
        }
        self.image = image
        self.contract = contract
    }

    public func frame(state: String, index: Int) throws -> NSImage {
        guard let row = contract.row(named: state) else {
            throw SpriteAtlasError.unknownState(state)
        }
        guard 0 ..< row.frames ~= index else {
            throw SpriteAtlasError.frameOutOfRange(state: state, index: index)
        }

        let cellWidth = contract.atlas.cellPixelSize[0]
        let cellHeight = contract.atlas.cellPixelSize[1]
        let sourceRect = CGRect(
            x: index * cellWidth,
            y: image.height - ((row.index + 1) * cellHeight),
            width: cellWidth,
            height: cellHeight
        )
        guard let cropped = image.cropping(to: sourceRect) else {
            throw SpriteAtlasError.cropFailed
        }
        return NSImage(
            cgImage: cropped,
            size: NSSize(
                width: contract.atlas.cellPointSize[0],
                height: contract.atlas.cellPointSize[1]
            )
        )
    }
}
