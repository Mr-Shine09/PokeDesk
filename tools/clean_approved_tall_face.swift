#!/usr/bin/env swift

import AppKit
import Foundation

enum ApprovedFaceError: Error {
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
let skinLight = RGBA(r: 255, g: 190, b: 75, a: 255)
let skin = RGBA(r: 225, g: 139, b: 48, a: 255)
let skinShadow = RGBA(r: 167, g: 82, b: 33, a: 255)
let lensGlint = RGBA(r: 246, g: 243, b: 228, a: 255)

func writePNG(_ image: CGImage, to path: String) throws {
    let representation = NSBitmapImageRep(cgImage: image)
    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw ApprovedFaceError.unwritableOutput
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
        throw ApprovedFaceError.unwritableOutput
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
        throw ApprovedFaceError.unwritableOutput
    }
    return output
}

do {
    guard CommandLine.arguments.count == 4 else {
        throw ApprovedFaceError.usage
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
        throw ApprovedFaceError.unreadableInput
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
        throw ApprovedFaceError.unreadableInput
    }

    context.setAllowsAntialiasing(false)
    context.interpolationQuality = .none
    context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let rawData = context.data else {
        throw ApprovedFaceError.unreadableInput
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

    // Keep the approved source reduction's hair (rows 0...4) and the entire
    // neck-down tall body (rows 16...79). Only the underspecified face area is
    // rebuilt at native resolution.
    for topY in 5..<16 {
        line(27, 53, topY, clear)
    }

    // Proportionate 17-pixel face—smaller than the rejected goggle-bar patch.
    borderedLine(35, 45, 5, fill: skin)
    borderedLine(32, 48, 6, fill: skinLight)
    borderedLine(31, 49, 7, fill: skinLight)
    borderedLine(31, 49, 8, fill: skinLight)
    borderedLine(31, 49, 9, fill: skinLight)
    borderedLine(31, 49, 10, fill: skinLight)
    borderedLine(31, 49, 11, fill: skinLight)
    borderedLine(32, 48, 12, fill: skinLight)
    borderedLine(33, 47, 13, fill: skinLight)
    borderedLine(35, 45, 14, fill: skinLight)
    borderedLine(38, 42, 15, fill: skin)

    // Small ears sit outside the frames so they do not extend the glasses band.
    setPixel(x: 29, topY: 8, color: outline)
    setPixel(x: 30, topY: 8, color: skin)
    setPixel(x: 29, topY: 9, color: outline)
    setPixel(x: 30, topY: 9, color: skin)
    setPixel(x: 50, topY: 8, color: skin)
    setPixel(x: 51, topY: 8, color: outline)
    setPixel(x: 50, topY: 9, color: skin)
    setPixel(x: 51, topY: 9, color: outline)

    // Preserve the approved asymmetric fringe but stop it above row 6, leaving
    // a full warm-skin row before the glasses.
    line(31, 35, 5, hair)
    setPixel(x: 31, topY: 5, color: outline)
    line(43, 48, 5, hair)
    setPixel(x: 48, topY: 5, color: outline)

    // Two compact 6x4 square frames. A four-pixel warm-skin gap keeps them
    // visually independent; one isolated center pixel suggests the bridge
    // without recreating the rejected continuous goggle bar.
    line(32, 37, 7, outline)
    line(43, 48, 7, outline)
    setPixel(x: 32, topY: 8, color: outline)
    setPixel(x: 37, topY: 8, color: outline)
    setPixel(x: 43, topY: 8, color: outline)
    setPixel(x: 48, topY: 8, color: outline)
    setPixel(x: 40, topY: 8, color: outline)
    setPixel(x: 32, topY: 9, color: outline)
    setPixel(x: 37, topY: 9, color: outline)
    setPixel(x: 43, topY: 9, color: outline)
    setPixel(x: 48, topY: 9, color: outline)
    line(32, 37, 10, outline)
    line(43, 48, 10, outline)

    // Each lens owns one glint and one eye; there is no shared white visor.
    line(33, 36, 8, skinLight)
    line(44, 47, 8, skinLight)
    line(33, 36, 9, skinLight)
    line(44, 47, 9, skinLight)
    setPixel(x: 33, topY: 8, color: lensGlint)
    setPixel(x: 44, topY: 8, color: lensGlint)
    setPixel(x: 35, topY: 9, color: outline)
    setPixel(x: 46, topY: 9, color: outline)

    // Separate vertical facial stack: skin row, nose, skin row, mouth, jaw.
    setPixel(x: 40, topY: 11, color: skinShadow)
    line(39, 41, 13, skinShadow)

    guard let cleaned = context.makeImage() else {
        throw ApprovedFaceError.unreadableInput
    }
    try writePNG(cleaned, to: output)
    try writePNG(try reviewSheet(cleaned), to: reviewOutput)
    print("Wrote \(output) and \(reviewOutput)")
} catch ApprovedFaceError.usage {
    fputs("Usage: clean_approved_tall_face.swift <80x80-input.png> <output.png> <review-output.png>\n", stderr)
    exit(2)
} catch {
    fputs("Failed to clean approved tall face: \(error)\n", stderr)
    exit(1)
}
