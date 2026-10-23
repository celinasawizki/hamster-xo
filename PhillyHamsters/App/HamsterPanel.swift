import AppKit
import CoreGraphics

/// A borderless, transparent, non-activating panel that sits the hamster
/// scene on the desktop itself — visible when you're looking at the
/// desktop (or through/around other windows), but covered by any normal
/// application window, the same way desktop icons and desktop widgets
/// behave. Overriding `canBecomeKey`/`canBecomeMain` to `false` is what
/// actually prevents focus stealing — AppKit still delivers mouse events
/// (clicks, drags) to a panel that can never become key, so dragging and
/// tap-to-animate keep working.
final class HamsterPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    /// One tick above the desktop-icons layer, and far below
    /// `kCGNormalWindowLevel` (0) where every ordinary app window lives —
    /// so any app window the user opens draws over the hamsters, and they
    /// only show on a clear desktop.
    private static let desktopOverlayLevel = NSWindow.Level(
        rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1
    )

    convenience init(contentRect: NSRect) {
        self.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = Self.desktopOverlayLevel
        // Visible on every ordinary Space, but intentionally NOT
        // `.fullScreenAuxiliary` — that's what keeps it off fullscreen apps.
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        worksWhenModal = true
        isReleasedWhenClosed = false
    }
}
