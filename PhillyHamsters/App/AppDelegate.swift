import AppKit
import SwiftUI

/// Owns every long-lived piece of app state: the floating hamster panel, the
/// menu-bar status item, and the settings window. Kept as a single delegate
/// (rather than scattering ownership across SwiftUI scenes) because the pet
/// panel is a plain AppKit `NSPanel`, not a SwiftUI `WindowGroup`.
final class AppDelegate: NSObject, NSApplicationDelegate {
    let settingsStore = SettingsStore()
    let countdownModel = CountdownModel()

    private var countdownScheduler: CountdownScheduler?
    private var panelController: HamsterPanelController?
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Desktop-pet apps have no Dock icon and no main window; everything
        // lives in the menu bar + the floating panel.
        NSApp.setActivationPolicy(.accessory)

        panelController = HamsterPanelController(
            countdownModel: countdownModel,
            settingsStore: settingsStore
        )
        panelController?.showPanel()

        countdownScheduler = CountdownScheduler(model: countdownModel)
        countdownScheduler?.start()

        setUpStatusItem()

        if settingsStore.launchAtLoginEnabled {
            LaunchAtLoginService.shared.syncSystemState(enabled: true)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        countdownScheduler?.stop()
    }

    // MARK: - Menu bar

    private func setUpStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = NSImage(
                systemSymbolName: "pawprint.fill",
                accessibilityDescription: "Philly Hamsters"
            )
            button.toolTip = "Philly Hamsters"
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(withTitle: "Reset Mascot Position", action: #selector(resetPosition), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Philly Hamsters", action: #selector(quit), keyEquivalent: "q")
        for menuItem in menu.items {
            menuItem.target = self
        }
        item.menu = menu
        statusItem = item
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 360, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "Philly Hamsters Settings"
            window.isReleasedWhenClosed = false
            window.center()
            window.contentView = NSHostingView(
                rootView: SettingsView(store: settingsStore)
            )
            settingsWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func resetPosition() {
        panelController?.resetPosition()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
