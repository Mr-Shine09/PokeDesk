#!/usr/bin/env swift

import AppKit
import Foundation

enum ConceptError: Error, CustomStringConvertible {
    case usage
    case unreadableImage(String)
    case missingVisiblePixels
    case outputFailed(String)

    var description: String {
        switch self {
        case .usage:
            return "Usage: prepare_pixel_concept.swift <input.png> <native-size> <native-output.png> <review-output.png>"
        case let .unreadableImage(path):
            return "Could not read image: \(path)"
        case .missingVisiblePixels:
            return "Input has no visible pixels"
        case let .outputFailed(path):
            return "Could not write image: \(path)"
        }
    }
}

func normalizedImage(at path: String) throws -> CGImage {
    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
        let bitmap = NSBitmapImageRep(data: data),
        let source = bitmap.cgImage
    else {
        throw ConceptError.unreadableImage(path)
    }

    let width = source.width
    let height = source.height
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw ConceptError.unreadableImage(path)
    }

    context.interpolationQuality = .none
    context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let normalized = context.makeImage() else {
        throw ConceptError.unreadableImage(path)
    }
    return normalized
}

func visibleBounds(of image: CGImage) throws -> CGRect {
    let width = image.width
    let height = image.height
    let bytesPerRow = width * 4
    var pixels = [UInt8](repeating: 0, count: bytesPerRow * height)
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    guard let context = CGContext(
        data: &pixels,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw ConceptError.missingVisiblePixels
    }

    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

    var minX = width
    var minY = height
    var maxX = -1
    var maxY = -1
    for y in 0..<height {
        for x in 0..<width where pixels[y * bytesPerRow + x * 4 + 3] > 16 {
            minX = min(minX, x)
            minY = min(minY, y)
            maxX = max(maxX, x)
            maxY = max(maxY, y)
        }
    }

    guard maxX >= minX, maxY >= minY else {
        throw ConceptError.missingVisiblePixels
    }
    return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
}

func quantized(_ image: CGImage) throws -> CGImage {
    let palette: [(r: UInt8, g: UInt8, b: UInt8)] = [
        (17, 18, 25),   // outline
        (37, 37, 43),   // hair
        (62, 61, 67),   // hair highlight
        (255, 190, 75), // skin light
        (225, 139, 48), // skin
        (167, 82, 33),  // skin shadow / sole
        (18, 47, 104),  // navy shadow
        (27, 66, 139),  // navy
        (246, 243, 228),// white panels
        (181, 182, 184),// trouser light
        (126, 128, 133),// trouser shadow
        (13, 35, 78)    // shoe navy
    ]

    let width = image.width
    let height = image.height
    let bytesPerRow = width * 4
    var pixels = [UInt8](repeating: 0, count: bytesPerRow * height)
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    guard let context = CGContext(
        data: &pixels,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw ConceptError.missingVisiblePixels
    }

    context.setAllowsAntialiasing(false)
    context.interpolationQuality = .none
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

    for index in stride(from: 0, to: pixels.count, by: 4) {
        let alpha = pixels[index + 3]
        if alpha < 128 {
            pixels[index] = 0
            pixels[index + 1] = 0
            pixels[index + 2] = 0
            pixels[index + 3] = 0
            continue
        }

        let red = Int(pixels[index]) * 255 / max(1, Int(alpha))
        let green = Int(pixels[index + 1]) * 255 / max(1, Int(alpha))
        let blue = Int(pixels[index + 2]) * 255 / max(1, Int(alpha))
        let nearest = palette.min { lhs, rhs in
            let lhsDistance = (red - Int(lhs.r)) * (red - Int(lhs.r))
                + (green - Int(lhs.g)) * (green - Int(lhs.g))
                + (blue - Int(lhs.b)) * (blue - Int(lhs.b))
            let rhsDistance = (red - Int(rhs.r)) * (red - Int(rhs.r))
                + (green - Int(rhs.g)) * (green - Int(rhs.g))
                + (blue - Int(rhs.b)) * (blue - Int(rhs.b))
            return lhsDistance < rhsDistance
        }!
        pixels[index] = nearest.r
        pixels[index + 1] = nearest.g
        pixels[index + 2] = nearest.b
        pixels[index + 3] = 255
    }

    guard let output = context.makeImage() else {
        throw ConceptError.missingVisiblePixels
    }
    return output
}

func renderNative(_ source: CGImage, size: Int) throws -> CGImage {
    let bounds = try visibleBounds(of: source)
    let inset = 1
    let available = CGFloat(size - inset * 2)
    let scale = min(available / bounds.width, available / bounds.height)
    let drawnWidth = max(1, floor(bounds.width * scale))
    let targetX = floor((CGFloat(size) - drawnWidth) / 2)
    let targetY = CGFloat(inset)

    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    guard let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: size * 4,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw ConceptError.missingVisiblePixels
    }

    context.setAllowsAntialiasing(false)
    context.interpolationQuality = .none
    context.clear(CGRect(x: 0, y: 0, width: size, height: size))
    let sourceRect = CGRect(
        x: targetX - bounds.minX * scale,
        y: targetY - bounds.minY * scale,
        width: CGFloat(source.width) * scale,
        height: CGFloat(source.height) * scale
    )
    context.draw(source, in: sourceRect)
    guard let output = context.makeImage() else {
        throw ConceptError.missingVisiblePixels
    }
    return try quantized(output)
}

func reviewSheet(_ source: CGImage, factor: Int) throws -> CGImage {
    let panelWidth = source.width * factor
    let width = panelWidth * 2
    let height = source.height * factor
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw ConceptError.missingVisiblePixels
    }

    context.setFillColor(red: 240.0 / 255.0, green: 238.0 / 255.0, blue: 228.0 / 255.0, alpha: 1)
    context.fill(CGRect(x: 0, y: 0, width: panelWidth, height: height))
    context.setFillColor(red: 36.0 / 255.0, green: 39.0 / 255.0, blue: 51.0 / 255.0, alpha: 1)
    context.fill(CGRect(x: panelWidth, y: 0, width: panelWidth, height: height))
    context.setAllowsAntialiasing(false)
    context.interpolationQuality = .none
    context.draw(source, in: CGRect(x: 0, y: 0, width: panelWidth, height: height))
    context.draw(source, in: CGRect(x: panelWidth, y: 0, width: panelWidth, height: height))
    guard let output = context.makeImage() else {
        throw ConceptError.missingVisiblePixels
    }
    return output
}

func writePNG(_ image: CGImage, to path: String) throws {
    let representation = NSBitmapImageRep(cgImage: image)
    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw ConceptError.outputFailed(path)
    }
    do {
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    } catch {
        throw ConceptError.outputFailed(path)
    }
}

do {
    guard CommandLine.arguments.count == 5, let size = Int(CommandLine.arguments[2]), size > 0 else {
        throw ConceptError.usage
    }
    let source = try normalizedImage(at: CommandLine.arguments[1])
    let native = try renderNative(source, size: size)
    let review = try reviewSheet(native, factor: 8)
    try writePNG(native, to: CommandLine.arguments[3])
    try writePNG(review, to: CommandLine.arguments[4])
    print("Wrote \(CommandLine.arguments[3]) and \(CommandLine.arguments[4])")
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
