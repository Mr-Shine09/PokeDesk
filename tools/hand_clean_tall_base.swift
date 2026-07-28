#!/usr/bin/env swift

import AppKit
import Foundation

enum CleanError: Error {
    case usage
    case unreadableInput
    case unwritableOutput
}

let palette: [Character: (r: UInt8, g: UInt8, b: UInt8, a: UInt8)] = [
    ".": (0, 0, 0, 0),
    "K": (17, 18, 25, 255),
    "H": (37, 37, 43, 255),
    "h": (62, 61, 67, 255),
    "L": (255, 190, 75, 255),
    "S": (225, 139, 48, 255),
    "s": (167, 82, 33, 255),
    "W": (246, 243, 228, 255)
]

// Top-down 40x11 replacement for the generated head. The body below row 10 is
// preserved from the selected tall concept.
let head = [
    ".................HHH....................",
    "...............HHhhhHH..................",
    "..............HhhhhhhHH.................",
    ".............HHHHHHHHHHHH...............",
    ".............HHHLLLLLHHHH...............",
    ".............SKKKKKLKKKKKS..............",
    ".............SKKWKKKKKWKKS..............",
    ".............SKKKKKLKKKKKS..............",
    ".............SLLLLLsLLLLLS..............",
    "...............LLLsssLLL................",
    ".................SSS...................."
]

func writePNG(_ image: CGImage, to path: String) throws {
    let representation = NSBitmapImageRep(cgImage: image)
    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw CleanError.unwritableOutput
    }
    try data.write(to: URL(fileURLWithPath: path), options: .atomic)
}

func reviewSheet(_ source: CGImage, factor: Int = 8) throws -> CGImage {
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
        throw CleanError.unwritableOutput
    }

    context.setFillColor(red: 240 / 255, green: 238 / 255, blue: 228 / 255, alpha: 1)
    context.fill(CGRect(x: 0, y: 0, width: panelWidth, height: height))
    context.setFillColor(red: 36 / 255, green: 39 / 255, blue: 51 / 255, alpha: 1)
    context.fill(CGRect(x: panelWidth, y: 0, width: panelWidth, height: height))
    context.setAllowsAntialiasing(false)
    context.interpolationQuality = .none
    context.draw(source, in: CGRect(x: 0, y: 0, width: panelWidth, height: height))
    context.draw(source, in: CGRect(x: panelWidth, y: 0, width: panelWidth, height: height))
    guard let output = context.makeImage() else {
        throw CleanError.unwritableOutput
    }
    return output
}

do {
    guard CommandLine.arguments.count == 4 else {
        throw CleanError.usage
    }
    let input = CommandLine.arguments[1]
    let output = CommandLine.arguments[2]
    let reviewOutput = CommandLine.arguments[3]
    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: input)),
        let representation = NSBitmapImageRep(data: data),
        let source = representation.cgImage,
        source.width == 40,
        source.height == 40
    else {
        throw CleanError.unreadableInput
    }

    let width = 40
    let height = 40
    let bytesPerRow = width * 4
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw CleanError.unreadableInput
    }
    context.setAllowsAntialiasing(false)
    context.interpolationQuality = .none
    context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let rawData = context.data else {
        throw CleanError.unreadableInput
    }
    let pixels = rawData.assumingMemoryBound(to: UInt8.self)

    for topY in 0..<head.count {
        for (x, symbol) in head[topY].enumerated() {
            guard let color = palette[symbol] else { continue }
            let index = topY * bytesPerRow + x * 4
            pixels[index] = color.r
            pixels[index + 1] = color.g
            pixels[index + 2] = color.b
            pixels[index + 3] = color.a
        }
    }

    guard let cleaned = context.makeImage() else {
        throw CleanError.unreadableInput
    }
    try writePNG(cleaned, to: output)
    try writePNG(try reviewSheet(cleaned), to: reviewOutput)
    print("Wrote \(output) and \(reviewOutput)")
} catch CleanError.usage {
    fputs("Usage: hand_clean_tall_base.swift <40x40-input.png> <output.png> <review-output.png>\n", stderr)
    exit(2)
} catch {
    fputs("Failed to hand-clean tall base: \(error)\n", stderr)
    exit(1)
}
