#!/usr/bin/swift
// Generates placeholder PhillyHamsters app icon PNGs at every size the
// AppIcon.appiconset Contents.json expects. Draws a simple rounded-square
// badge with two overlapping circles (the "two hamsters") so the app has a
// real, buildable icon before Codex delivers final artwork.
import AppKit

let sizes: [(name: String, pixels: CGFloat)] = [
    ("icon_16", 16), ("icon_32", 32), ("icon_64", 64),
    ("icon_128", 128), ("icon_256", 256), ("icon_512", 512), ("icon_1024", 1024)
]

let outputDir = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "PhillyHamsters/Assets/Assets.xcassets/AppIcon.appiconset"

func drawIcon(pixels: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: pixels, height: pixels))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: pixels, height: pixels)
    let background = NSBezierPath(roundedRect: rect, xRadius: pixels * 0.22, yRadius: pixels * 0.22)
    NSColor(calibratedRed: 0.73, green: 0.45, blue: 0.62, alpha: 1.0).setFill()
    background.fill()

    let girlColor = NSColor(calibratedRed: 0.96, green: 0.90, blue: 0.80, alpha: 1.0)
    let boyColor = NSColor(calibratedRed: 0.80, green: 0.60, blue: 0.38, alpha: 1.0)

    let radius = pixels * 0.30
    let centerY = pixels * 0.46

    let boyRect = NSRect(x: pixels * 0.50 - radius * 0.5, y: centerY - radius * 0.5, width: radius, height: radius)
    boyColor.setFill()
    NSBezierPath(ovalIn: boyRect).fill()

    let girlRect = NSRect(x: pixels * 0.30 - radius * 0.5, y: centerY - radius * 0.5, width: radius, height: radius)
    girlColor.setFill()
    NSBezierPath(ovalIn: girlRect).fill()

    image.unlockFocus()
    return image
}

func writePNG(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Failed to encode PNG for \(path)")
    }
    FileManager.default.createFile(atPath: path, contents: png)
}

for entry in sizes {
    let image = drawIcon(pixels: entry.pixels)
    let path = "\(outputDir)/\(entry.name).png"
    writePNG(image, to: path)
    print("Wrote \(path)")
}
