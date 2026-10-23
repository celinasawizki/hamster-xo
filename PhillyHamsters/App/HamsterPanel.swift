import AppKit

/// A borderless, transparent, non-activating panel that floats the hamster
/// scene over the desktop. Overriding `canBecomeKey`/`canBecomeMain` to
/// `false` is what actually prevents focus stealing — AppKit still
/// delivers mouse events (clicks, drags) to a panel that can never become
/// key, so dragging and tap-to-animate keep working.
final class HamsterPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

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
        level = .floating
        // Visible on every ordinary Space, but intentionally NOT
        // `.fullScreenAuxiliary` — that's what keeps it off fullscreen apps.
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        worksWhenModal = true
        isReleasedWhenClosed = false
    }
}
