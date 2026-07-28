#!/usr/bin/env swift

import AppKit
import Foundation

enum FaceCleanError: Error {
    case usage
    case unreadableInput
    case unwritableOutput
}

struct RGBA {
    let r: UInt8
    let g: UInt8
    let b: UInt8
    let a: UInt8
}

let clear = RGBA(r: 0, g: 0, b: 0, a: 0)
let outline = RGBA(r: 17, g: 18, b: 25, a: 255)
let hair = RGBA(r: 37, g: 37, b: 43, a: 255)
let hairLight = RGBA(r: 62, g: 61, b: 67, a: 255)
let skinLight = RGBA(r: 255, g: 190, b: 75, a: 255)
let skin = RGBA(r: 225, g: 139, b: 48, a: 255)
let skinShadow = RGBA(r: 167, g: 82, b: 33, a: 255)
let lensGlint = RGBA(r: 246, g: 243, b: 228, a: 255)

func writePNG(_ image: CGImage, to path: String) throws {
    let representation = NSBitmapImageRep(cgImage: image)
    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw FaceCleanError.unwritableOutput
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
        throw FaceCleanError.unwritableOutput
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
        throw FaceCleanError.unwritableOutput
    }
    return output
}

do {
    guard CommandLine.arguments.count == 4 else {
        throw FaceCleanError.usage
    }

    let input = CommandLine.arguments[1]
    let output = CommandLine.arguments[2]
    let reviewOutput = CommandLine.arguments[3]
    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: input)),
        let representation = NSBitmapImageRep(data: data),
        let source = representation.cgImage,
        source.width == 80,
        source.height == 80
    else {
        throw FaceCleanError.unreadableInput
    }

    let width = 80
    let height = 80
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
        throw FaceCleanError.unreadableInput
    }

    context.setAllowsAntialiasing(false)
    context.interpolationQuality = .none
    context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let rawData = context.data else {
        throw FaceCleanError.unreadableInput
    }
    let pixels = rawData.assumingMemoryBound(to: UInt8.self)

    func setPixel(x: Int, topY: Int, color: RGBA) {
        guard (0..<width).contains(x), (0..<height).contains(topY) else { return }
        let index = topY * bytesPerRow + x * 4
        pixels[index] = color.r
        pixels[index + 1] = color.g
        pixels[index + 2] = color.b
        pixels[index + 3] = color.a
    }

    func line(_ x0: Int, _ x1: Int, _ topY: Int, _ color: RGBA) {
        for x in x0...x1 {
            setPixel(x: x, topY: topY, color: color)
        }
    }

    func borderedLine(_ x0: Int, _ x1: Int, _ topY: Int, fill: RGBA) {
        line(x0, x1, topY, outline)
        if x1 - x0 >= 2 {
            line(x0 + 1, x1 - 1, topY, fill)
        }
    }

    // Replace only the generated head. Rows 16...79—the neck-down selected
    // body and its tall proportions—remain byte-for-byte unchanged.
    for topY in 0..<16 {
        line(26, 54, topY, clear)
    }

    // Warm face base with a compact jaw. Its wider backing-pixel allocation is
    // intentional: this still occupies roughly 12 points on a Retina display.
    borderedLine(36, 44, 4, fill: skin)
    borderedLine(33, 47, 5, fill: skinLight)
    borderedLine(31, 49, 6, fill: skinLight)
    borderedLine(29, 51, 7, fill: skinLight)
    borderedLine(29, 51, 8, fill: skinLight)
    borderedLine(29, 51, 9, fill: skinLight)
    borderedLine(29, 51, 10, fill: skinLight)
    borderedLine(29, 51, 11, fill: skinLight)
    borderedLine(30, 50, 12, fill: skinLight)
    borderedLine(31, 49, 13, fill: skinLight)
    borderedLine(33, 47, 14, fill: skinLight)
    borderedLine(36, 44, 15, fill: skin)

    // Separate ears remain outside the frames rather than extending the frame
    // band. This prevents the face from reading as one horizontal visor.
    line(27, 28, 8, outline)
    setPixel(x: 28, topY: 8, color: skin)
    line(27, 28, 9, outline)
    setPixel(x: 28, topY: 9, color: skin)
    line(27, 28, 10, outline)
    setPixel(x: 28, topY: 10, color: skin)
    line(52, 53, 8, outline)
    setPixel(x: 52, topY: 8, color: skin)
    line(52, 53, 9, outline)
    setPixel(x: 52, topY: 9, color: skin)
    line(52, 53, 10, outline)
    setPixel(x: 52, topY: 10, color: skin)

    // Asymmetric hair mass. The fringe ends on row 5, leaving a full warm-skin
    // row (row 6) before the glasses start on row 7.
    borderedLine(37, 45, 0, fill: hair)
    borderedLine(34, 48, 1, fill: hair)
    borderedLine(32, 51, 2, fill: hair)
    borderedLine(31, 52, 3, fill: hair)
    borderedLine(30, 53, 4, fill: hair)
    line(30, 35, 5, outline)
    line(31, 34, 5, hair)
    line(37, 40, 5, hair)
    line(43, 46, 5, hair)
    line(49, 52, 5, hair)
    setPixel(x: 53, topY: 5, color: outline)
    line(30, 32, 6, outline)
    setPixel(x: 31, topY: 6, color: hair)
    line(49, 52, 6, outline)
    line(50, 51, 6, hair)
    setPixel(x: 38, topY: 1, color: hairLight)
    setPixel(x: 35, topY: 2, color: hairLight)
    setPixel(x: 34, topY: 3, color: hairLight)
    setPixel(x: 47, topY: 3, color: hairLight)

    // Two independent 7x4 frames. The only connection is the single backing-
    // pixel-high bridge on row 8; the remaining center pixels stay warm skin.
    line(32, 38, 7, outline)
    line(42, 48, 7, outline)
    setPixel(x: 32, topY: 8, color: outline)
    setPixel(x: 38, topY: 8, color: outline)
    setPixel(x: 42, topY: 8, color: outline)
    setPixel(x: 48, topY: 8, color: outline)
    line(38, 42, 8, outline)
    setPixel(x: 32, topY: 9, color: outline)
    setPixel(x: 38, topY: 9, color: outline)
    setPixel(x: 42, topY: 9, color: outline)
    setPixel(x: 48, topY: 9, color: outline)
    line(32, 38, 10, outline)
    line(42, 48, 10, outline)

    // Individual lenses, eyes, and highlights. There is no shared white strip.
    line(33, 37, 8, skinLight)
    line(43, 47, 8, skinLight)
    line(33, 37, 9, skinLight)
    line(43, 47, 9, skinLight)
    setPixel(x: 34, topY: 8, color: lensGlint)
    setPixel(x: 44, topY: 8, color: lensGlint)
    setPixel(x: 36, topY: 9, color: outline)
    setPixel(x: 46, topY: 9, color: outline)

    // Nose and mouth are isolated below the glasses by warm-skin rows.
    setPixel(x: 40, topY: 12, color: skinShadow)
    line(39, 41, 14, skinShadow)

    guard let cleaned = context.makeImage() else {
        throw FaceCleanError.unreadableInput
    }
    try writePNG(cleaned, to: output)
    try writePNG(try reviewSheet(cleaned), to: reviewOutput)
    print("Wrote \(output) and \(reviewOutput)")
} catch FaceCleanError.usage {
    fputs("Usage: clean_retina_face.swift <80x80-input.png> <output.png> <review-output.png>\n", stderr)
    exit(2)
} catch {
    fputs("Failed to clean Retina face: \(error)\n", stderr)
    exit(1)
}
