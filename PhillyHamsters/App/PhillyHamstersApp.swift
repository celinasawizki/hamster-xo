import SwiftUI

@main
struct PhillyHamstersApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView(store: appDelegate.settingsStore)
        }
    }
}
