import AppKit

extension NSImage {
    /// Crops frame `index` out of a horizontal-strip sprite sheet with
    /// `frameCount` equal-width frames. Returns `nil` if the index/sheet
    /// geometry doesn't line up (e.g. a mis-sized placeholder).
    func spriteFrame(index: Int, frameCount: Int) -> NSImage? {
        guard frameCount > 0, size.width > 0, size.height > 0 else { return nil }
        let frameWidth = size.width / CGFloat(frameCount)
        let sourceRect = NSRect(x: frameWidth * CGFloat(index), y: 0, width: frameWidth, height: size.height)

        let frameImage = NSImage(size: NSSize(width: frameWidth, height: size.height))
        frameImage.lockFocus()
        draw(
            in: NSRect(origin: .zero, size: frameImage.size),
            from: sourceRect,
            operation: .copy,
            fraction: 1.0
        )
        frameImage.unlockFocus()
        return frameImage
    }
}
