#!/usr/bin/swift
// Procedurally generates real pixel-art sprite sheets for both hamsters and
// writes them straight into the Assets.xcassets imagesets that
// SpriteCatalog.swift expects (see DESIGN_HANDOFF.md for the asset list).
//
// Characters are drawn into a small, non-antialiased grid (so edges land on
// hard pixel boundaries) and then scaled up with nearest-neighbor
// interpolation — the standard way to get crisp "chunky pixel" art from
// vector primitives instead of a smooth vector look.
//
// Run with: swift scripts/generate_sprites.swift
import AppKit

// MARK: - Palette

struct HamsterPalette {
    let fur: NSColor
    let belly: NSColor
    let outline: NSColor
    let innerEar: NSColor
    let cheek: NSColor
    let nose: NSColor
    let bow: NSColor?
}

let celinaPalette = HamsterPalette(
    fur: NSColor(calibratedRed: 0.97, green: 0.85, blue: 0.68, alpha: 1),
    belly: NSColor(calibratedRed: 1.0, green: 0.95, blue: 0.88, alpha: 1),
    outline: NSColor(calibratedRed: 0.42, green: 0.29, blue: 0.19, alpha: 1),
    innerEar: NSColor(calibratedRed: 0.98, green: 0.72, blue: 0.70, alpha: 1),
    cheek: NSColor(calibratedRed: 0.98, green: 0.62, blue: 0.58, alpha: 0.75),
    nose: NSColor(calibratedRed: 0.55, green: 0.33, blue: 0.30, alpha: 1),
    bow: NSColor(calibratedRed: 0.93, green: 0.45, blue: 0.56, alpha: 1)
)

let kivancPalette = HamsterPalette(
    fur: NSColor(calibratedRed: 0.80, green: 0.60, blue: 0.38, alpha: 1),
    belly: NSColor(calibratedRed: 0.95, green: 0.85, blue: 0.70, alpha: 1),
    outline: NSColor(calibratedRed: 0.35, green: 0.22, blue: 0.12, alpha: 1),
    innerEar: NSColor(calibratedRed: 0.93, green: 0.68, blue: 0.60, alpha: 1),
    cheek: NSColor(calibratedRed: 0.95, green: 0.58, blue: 0.50, alpha: 0.65),
    nose: NSColor(calibratedRed: 0.45, green: 0.28, blue: 0.22, alpha: 1),
    bow: nil
)

func palette(for role: String) -> HamsterPalette {
    role == "celina" ? celinaPalette : kivancPalette
}

// MARK: - Pose

enum EyeState { case open, halfClosed, closed, sadDroop, happyArc }
enum ArmPose { case down, clasped, raisedBoth, reachRight, reachLeft, onHip }

struct Pose {
    var eyes: EyeState = .open
    var arms: ArmPose = .clasped
    var jumpOffset: CGFloat = 0
    var blush: Bool = false
    var openMouth: Bool = false
}

// MARK: - Low-level pixel canvas

final class PixelCanvas {
    let rep: NSBitmapImageRep
    let ctx: NSGraphicsContext

    init(width: Int, height: Int) {
        rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!
        ctx = NSGraphicsContext(bitmapImageRep: rep)!
    }

    func draw(_ body: () -> Void) {
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = ctx
        ctx.shouldAntialias = false
        ctx.cgContext.setShouldAntialias(false)
        ctx.cgContext.interpolationQuality = .none
        body()
        NSGraphicsContext.restoreGraphicsState()
    }

    /// Nearest-neighbor upscale into a new canvas of the given size.
    func upscaled(toWidth width: Int, height: Int) -> PixelCanvas {
        let out = PixelCanvas(width: width, height: height)
        out.draw {
            out.ctx.imageInterpolation = .none
            out.ctx.cgContext.interpolationQuality = .none
            if let cg = rep.cgImage {
                out.ctx.cgContext.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        }
        return out
    }
}

func fillRect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: NSColor) {
    color.setFill()
    NSBezierPath(rect: NSRect(x: x, y: y, width: w, height: h)).fill()
}

func fillOval(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: NSColor) {
    color.setFill()
    NSBezierPath(ovalIn: NSRect(x: x, y: y, width: w, height: h)).fill()
}

func strokeOval(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: NSColor, _ lineWidth: CGFloat) {
    let path = NSBezierPath(ovalIn: NSRect(x: x, y: y, width: w, height: h))
    path.lineWidth = lineWidth
    color.setStroke()
    path.stroke()
}

// MARK: - Character drawing (grid units; origin bottom-left, y-up)

/// Draws one hamster, front-facing, centered horizontally on `centerX` with
/// its feet resting on `baseY` (before `pose.jumpOffset` lifts it).
func drawHamster(_ palette: HamsterPalette, pose: Pose, centerX: CGFloat, baseY: CGFloat, drawBow: Bool) {
    let lift = pose.jumpOffset
    let legLift = max(0, lift - 3) // legs stay grounded through a small crouch/stretch before lifting off

    // Feet (lift only once airborne).
    fillOval(centerX - 7, baseY + legLift, 5, 3.5, palette.belly)
    fillOval(centerX + 2, baseY + legLift, 5, 3.5, palette.belly)

    let bodyBottom = baseY + 2 + lift
    let bodyW: CGFloat = 20
    let bodyH: CGFloat = 19

    // Ears (behind body).
    func ear(atX x: CGFloat, y: CGFloat) {
        fillOval(x - 3, y - 3, 6, 6, palette.fur)
        strokeOval(x - 3, y - 3, 6, 6, palette.outline, 0.7)
        fillOval(x - 1.5, y - 1.8, 3, 3, palette.innerEar)
    }
    ear(atX: centerX - 7, y: bodyBottom + bodyH - 2)
    ear(atX: centerX + 7, y: bodyBottom + bodyH - 2)

    // Body.
    fillOval(centerX - bodyW / 2, bodyBottom, bodyW, bodyH, palette.fur)
    strokeOval(centerX - bodyW / 2, bodyBottom, bodyW, bodyH, palette.outline, 0.9)

    // Belly.
    fillOval(centerX - 6, bodyBottom + 2, 12, 10, palette.belly)

    // Arms (drawn on top of the body so they're actually visible).
    func arm(atX x: CGFloat, raisedY: CGFloat) {
        fillOval(x, raisedY, 4, 8, palette.belly)
        strokeOval(x, raisedY, 4, 8, palette.outline, 0.6)
    }
    switch pose.arms {
    case .down:
        arm(atX: centerX - bodyW / 2 - 1, raisedY: bodyBottom + 2)
        arm(atX: centerX + bodyW / 2 - 3, raisedY: bodyBottom + 2)
    case .clasped:
        // One merged paw shape — two overlapping stroked ovals here would
        // double up their outlines into a distracting "teeth" pattern.
        fillOval(centerX - 3, bodyBottom + 1, 6, 5.5, palette.belly)
        strokeOval(centerX - 3, bodyBottom + 1, 6, 5.5, palette.outline, 0.6)
    case .raisedBoth:
        arm(atX: centerX - bodyW / 2 - 1, raisedY: bodyBottom + bodyH - 7)
        arm(atX: centerX + bodyW / 2 - 3, raisedY: bodyBottom + bodyH - 7)
    case .reachRight:
        arm(atX: centerX - bodyW / 2 - 1, raisedY: bodyBottom + 4)
        arm(atX: centerX + bodyW / 2 + 1, raisedY: bodyBottom + 7)
    case .reachLeft:
        arm(atX: centerX - bodyW / 2 - 5, raisedY: bodyBottom + 7)
        arm(atX: centerX + bodyW / 2 - 3, raisedY: bodyBottom + 4)
    case .onHip:
        arm(atX: centerX - bodyW / 2 - 1, raisedY: bodyBottom + 5)
        arm(atX: centerX + bodyW / 2 - 3, raisedY: bodyBottom + 5)
    }

    // Cheeks.
    let cheekY = bodyBottom + bodyH * 0.52
    let cheekScale: CGFloat = pose.blush ? 1.3 : 1.0
    fillOval(centerX - 9, cheekY, 5 * cheekScale, 4 * cheekScale, palette.cheek)
    fillOval(centerX + 4, cheekY, 5 * cheekScale, 4 * cheekScale, palette.cheek)

    // Eyes.
    let eyeY = bodyBottom + bodyH * 0.62
    func eye(atX x: CGFloat) {
        switch pose.eyes {
        case .open:
            fillOval(x, eyeY, 2.2, 2.2, palette.outline)
        case .halfClosed:
            fillRect(x, eyeY + 0.6, 2.2, 1.0, palette.outline)
        case .closed:
            fillRect(x, eyeY + 1.0, 2.6, 0.7, palette.outline)
        case .sadDroop:
            fillRect(x - 0.3, eyeY + 0.3, 2.6, 0.8, palette.outline)
        case .happyArc:
            fillRect(x, eyeY + 1.2, 2.4, 0.8, palette.outline)
        }
    }
    eye(atX: centerX - 4.6)
    eye(atX: centerX + 2.4)

    // Nose.
    fillOval(centerX - 0.8, bodyBottom + bodyH * 0.5, 1.6, 1.4, palette.nose)

    // Mouth (only when happily open, e.g. excited/celebration peak frames).
    if pose.openMouth {
        fillOval(centerX - 1.2, bodyBottom + bodyH * 0.40, 2.4, 1.8, palette.outline)
    }

    // Sad teardrop.
    if pose.eyes == .sadDroop {
        fillOval(centerX + 5.5, eyeY - 1.5, 1.4, 2.0, NSColor(calibratedRed: 0.55, green: 0.75, blue: 0.95, alpha: 0.85))
    }

    // Bow.
    if drawBow, let bowColor = palette.bow {
        let bowX = centerX - 7
        let bowY = bodyBottom + bodyH + 1
        fillOval(bowX - 2.2, bowY, 2.6, 2.6, bowColor)
        fillOval(bowX + 0.6, bowY, 2.6, 2.6, bowColor)
        fillOval(bowX - 0.7, bowY + 0.6, 1.6, 1.6, bowColor)
    }
}

/// Small blocky heart used as a decorative overlay (hugging/celebration).
func drawHeart(centerX: CGFloat, centerY: CGFloat, scale: CGFloat, color: NSColor) {
    let s = scale
    fillOval(centerX - 2.2 * s, centerY - 0.2 * s, 2.4 * s, 2.4 * s, color)
    fillOval(centerX - 0.2 * s, centerY - 0.2 * s, 2.4 * s, 2.4 * s, color)
    let path = NSBezierPath()
    path.move(to: NSPoint(x: centerX - 2.3 * s, y: centerY + 0.5 * s))
    path.line(to: NSPoint(x: centerX + 0.1 * s, y: centerY - 2.6 * s))
    path.line(to: NSPoint(x: centerX + 2.5 * s, y: centerY + 0.5 * s))
    path.close()
    color.setFill()
    path.fill()
}

/// Simple blocky "Z" for the sleeping state.
func drawZ(centerX: CGFloat, centerY: CGFloat, scale: CGFloat, color: NSColor) {
    let s = scale
    fillRect(centerX - 2 * s, centerY + 1.6 * s, 4 * s, 0.9 * s, color)
    fillRect(centerX - 2 * s, centerY - 1.6 * s, 4 * s, 0.9 * s, color)
    fillRect(centerX - 0.7 * s, centerY - 0.5 * s, 1.4 * s, 1.0 * s, color)
    fillRect(centerX + 0.3 * s, centerY + 0.5 * s, 1.4 * s, 1.0 * s, color)
}

// MARK: - Frame + sheet assembly

let outputRoot = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "PhillyHamsters/Assets/Assets.xcassets"

func writeSheet(assetName: String, frameSize: Int, frameWidth: Int? = nil, frameCount: Int, draw: (Int, PixelCanvas, Int) -> Void) {
    let gridH = 36 // a little headroom above the tallest jump/ear/bow extent
    let gridW = frameWidth != nil ? Int(Double(frameWidth!) / Double(frameSize) * Double(gridH)) : gridH
    let outFrameW = frameWidth ?? frameSize
    let outFrameH = frameSize

    let strip = PixelCanvas(width: outFrameW * frameCount, height: outFrameH)
    strip.draw {
        for i in 0..<frameCount {
            let low = PixelCanvas(width: gridW, height: gridH)
            low.draw {
                draw(i, low, gridW)
            }
            let hi = low.upscaled(toWidth: outFrameW, height: outFrameH)
            if let cg = hi.rep.cgImage {
                strip.ctx.cgContext.draw(cg, in: CGRect(x: outFrameW * i, y: 0, width: outFrameW, height: outFrameH))
            }
        }
    }

    let imagesetDir = "\(outputRoot)/\(assetName).imageset"
    try? FileManager.default.createDirectory(atPath: imagesetDir, withIntermediateDirectories: true)
    guard let png = strip.rep.representation(using: .png, properties: [:]) else {
        fatalError("Failed to encode PNG for \(assetName)")
    }
    let pngPath = "\(imagesetDir)/\(assetName).png"
    FileManager.default.createFile(atPath: pngPath, contents: png)

    let contents = """
    {
      "images" : [
        { "idiom" : "universal", "filename" : "\(assetName).png", "scale" : "1x" }
      ],
      "info" : { "author" : "xcode", "version" : 1 }
    }
    """
    try? contents.write(toFile: "\(imagesetDir)/Contents.json", atomically: true, encoding: .utf8)
    print("Wrote \(pngPath) (\(frameCount) frame\(frameCount == 1 ? "" : "s"))")
}

// MARK: - Solo sheets (idle / blink / excited) per character

func generateSolo(role: String) {
    let pal = palette(for: role)
    let bow = role == "celina"
    let baseY: CGFloat = 4

    writeSheet(assetName: "\(role)_idle", frameSize: 256, frameCount: 1) { _, canvas, gridW in
        drawHamster(pal, pose: Pose(eyes: .open, arms: .clasped), centerX: CGFloat(gridW) / 2, baseY: baseY, drawBow: bow)
    }

    let blinkEyes: [EyeState] = [.open, .halfClosed, .closed, .halfClosed]
    writeSheet(assetName: "\(role)_blink", frameSize: 256, frameCount: 4) { i, canvas, gridW in
        drawHamster(pal, pose: Pose(eyes: blinkEyes[i], arms: .clasped), centerX: CGFloat(gridW) / 2, baseY: baseY, drawBow: bow)
    }

    // Jump cycle: crouch, launch, peak, falling, land squash, settle.
    let jumpOffsets: [CGFloat] = [0, 2, 7, 4, 0, 0]
    let jumpArms: [ArmPose] = [.down, .raisedBoth, .raisedBoth, .raisedBoth, .down, .clasped]
    let jumpMouth = [false, true, true, true, false, false]
    writeSheet(assetName: "\(role)_excited", frameSize: 256, frameCount: 6) { i, canvas, gridW in
        drawHamster(
            pal,
            pose: Pose(eyes: .open, arms: jumpArms[i], jumpOffset: jumpOffsets[i], blush: true, openMouth: jumpMouth[i]),
            centerX: CGFloat(gridW) / 2, baseY: baseY, drawBow: bow
        )
    }
}

// MARK: - Pair sheets (both characters share one sprite sheet)

let pairFrameW = 512
let pairFrameH = 256

func generateHugging() {
    let frameCount = 8
    // Celina starts left-of-center, Kivanc right-of-center; they approach
    // across frames 0-4, embrace frames 5-7, heart appears frames 5-7.
    let approach: [CGFloat] = [0, 0.25, 0.5, 0.75, 1.0, 1.0, 1.0, 1.0]
    writeSheet(assetName: "pair_hugging", frameSize: pairFrameH, frameWidth: pairFrameW, frameCount: frameCount) { i, canvas, gridW in
        let gw = CGFloat(gridW)
        let t = approach[i]
        let celinaX = gw * 0.38 + t * gw * 0.08
        let kivancX = gw * 0.62 - t * gw * 0.08
        let embraced = i >= 5
        drawHamster(
            celinaPalette,
            pose: Pose(eyes: embraced ? .happyArc : .open, arms: embraced ? .reachRight : (t > 0 ? .reachRight : .clasped), blush: true),
            centerX: celinaX, baseY: 4, drawBow: true
        )
        drawHamster(
            kivancPalette,
            pose: Pose(eyes: embraced ? .happyArc : .open, arms: embraced ? .reachLeft : (t > 0 ? .reachLeft : .clasped), blush: true),
            centerX: kivancX, baseY: 4, drawBow: false
        )
        if embraced {
            let pulse: CGFloat = i % 2 == 0 ? 1.0 : 1.2
            drawHeart(centerX: gw / 2, centerY: 29, scale: pulse, color: NSColor(calibratedRed: 0.95, green: 0.4, blue: 0.5, alpha: 1))
        }
    }
}

func generateMissingYou() {
    let frameCount = 6
    let approach: [CGFloat] = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
    writeSheet(assetName: "pair_missing_you", frameSize: pairFrameH, frameWidth: pairFrameW, frameCount: frameCount) { i, canvas, gridW in
        let gw = CGFloat(gridW)
        let t = approach[i]
        let celinaX = gw * 0.34
        let kivancX = gw * 0.78 - t * gw * 0.18
        drawHamster(celinaPalette, pose: Pose(eyes: .sadDroop, arms: .down), centerX: celinaX, baseY: 4, drawBow: true)
        drawHamster(kivancPalette, pose: Pose(eyes: .open, arms: t > 0.5 ? .reachLeft : .down), centerX: kivancX, baseY: 4, drawBow: false)
    }
}

func generateSleeping() {
    writeSheet(assetName: "pair_sleeping", frameSize: pairFrameH, frameWidth: pairFrameW, frameCount: 2) { i, canvas, gridW in
        let gw = CGFloat(gridW)
        drawHamster(celinaPalette, pose: Pose(eyes: .closed, arms: .down), centerX: gw * 0.44, baseY: 4, drawBow: true)
        drawHamster(kivancPalette, pose: Pose(eyes: .closed, arms: .down), centerX: gw * 0.58, baseY: 4, drawBow: false)
        let scale: CGFloat = i == 0 ? 1.0 : 1.4
        drawZ(centerX: gw * 0.72, centerY: 26, scale: scale, color: NSColor(calibratedRed: 0.5, green: 0.45, blue: 0.5, alpha: 0.85))
    }
}

func generateCelebration() {
    let frameCount = 8
    let jumpOffsets: [CGFloat] = [0, 3, 7, 5, 1, 4, 7, 2]
    writeSheet(assetName: "pair_celebration", frameSize: pairFrameH, frameWidth: pairFrameW, frameCount: frameCount) { i, canvas, gridW in
        let gw = CGFloat(gridW)
        // The two hamsters hop slightly out of phase for a livelier feel.
        let celinaLift = jumpOffsets[i]
        let kivancLift = jumpOffsets[(i + 2) % frameCount]
        drawHamster(
            celinaPalette,
            pose: Pose(eyes: .happyArc, arms: .raisedBoth, jumpOffset: celinaLift, blush: true, openMouth: true),
            centerX: gw * 0.40, baseY: 4, drawBow: true
        )
        drawHamster(
            kivancPalette,
            pose: Pose(eyes: .happyArc, arms: .raisedBoth, jumpOffset: kivancLift, blush: true, openMouth: true),
            centerX: gw * 0.60, baseY: 4, drawBow: false
        )
        drawHeart(centerX: gw * 0.24, centerY: 18 + celinaLift, scale: 0.8, color: NSColor(calibratedRed: 0.95, green: 0.45, blue: 0.55, alpha: 0.9))
        drawHeart(centerX: gw * 0.76, centerY: 18 + kivancLift, scale: 0.8, color: NSColor(calibratedRed: 0.95, green: 0.45, blue: 0.55, alpha: 0.9))
    }
}

// MARK: - Run

generateSolo(role: "celina")
generateSolo(role: "kivanc")
generateHugging()
generateMissingYou()
generateSleeping()
generateCelebration()

print("Done. Re-run `xcodegen generate` is not required — Assets.xcassets is a single folder reference.")
