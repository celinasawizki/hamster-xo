import AppKit
import SwiftUI

/// Owns the `HamsterPanel`, positions it (persisting across restarts), and
/// keeps it correctly placed across screen/resolution changes.
final class HamsterPanelController: NSWindowController {
    static let panelSize = NSSize(width: 260, height: 210)

    private let positionStore = WindowPositionStore()
    private var screenChangeObserver: NSObjectProtocol?

    init(countdownModel: CountdownModel, settingsStore: SettingsStore) {
        let panel = HamsterPanel(contentRect: NSRect(origin: .zero, size: Self.panelSize))
        super.init(window: panel)

        let rootView = HamsterSceneView(countdownModel: countdownModel, settingsStore: settingsStore)
        panel.contentView = NSHostingView(rootView: rootView)

        applySavedOrDefaultPosition()

        screenChangeObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applySavedOrDefaultPosition()
        }

        NotificationCenter.default.addObserver(
            self, selector: #selector(windowDidMove),
            name: NSWindow.didMoveNotification, object: panel
        )

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleResetNotification),
            name: .resetMascotPosition, object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("HamsterPanelController does not support storyboard/XIB instantiation")
    }

    deinit {
        if let screenChangeObserver {
            NotificationCenter.default.removeObserver(screenChangeObserver)
        }
        NotificationCenter.default.removeObserver(self)
    }

    func showPanel() {
        window?.orderFrontRegardless()
    }

    func resetPosition() {
        positionStore.reset()
        applySavedOrDefaultPosition()
    }

    @objc private func handleResetNotification() {
        resetPosition()
    }

    @objc private func windowDidMove(_ notification: Notification) {
        guard let window, let screen = window.screen ?? NSScreen.main else { return }
        let inset = Self.inset(ofFrame: window.frame, fromBottomRightOf: screen.visibleFrame)
        positionStore.save(insetFromBottomRight: inset)
    }

    private func applySavedOrDefaultPosition() {
        guard let window, let screen = NSScreen.main else { return }
        let inset = positionStore.savedInsetFromBottomRight() ?? WindowPositionStore.defaultInset
        let visibleFrame = screen.visibleFrame
        let origin = NSPoint(
            x: visibleFrame.maxX - inset.width - Self.panelSize.width,
            y: visibleFrame.minY + inset.height
        )
        window.setFrameOrigin(clamp(origin, size: Self.panelSize, in: visibleFrame))
    }

    private func clamp(_ origin: NSPoint, size: NSSize, in bounds: NSRect) -> NSPoint {
        let x = min(max(origin.x, bounds.minX), bounds.maxX - size.width)
        let y = min(max(origin.y, bounds.minY), bounds.maxY - size.height)
        return NSPoint(x: x, y: y)
    }

    private static func inset(ofFrame frame: NSRect, fromBottomRightOf bounds: NSRect) -> NSSize {
        NSSize(
            width: bounds.maxX - frame.maxX,
            height: frame.minY - bounds.minY
        )
    }
}
