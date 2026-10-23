import Foundation
import Combine

/// User-facing preferences, persisted to `UserDefaults`. Deliberately tiny:
/// no accounts, no analytics, no network access — everything the Settings
/// window exposes lives here.
final class SettingsStore: ObservableObject {
    private enum Keys {
        static let launchAtLogin = "launchAtLoginEnabled"
        static let animationsEnabled = "animationsEnabled"
        static let soundEffectsEnabled = "soundEffectsEnabled"
        static let countdownVisible = "countdownVisible"
    }

    private let defaults: UserDefaults

    @Published var launchAtLoginEnabled: Bool {
        didSet {
            defaults.set(launchAtLoginEnabled, forKey: Keys.launchAtLogin)
            LaunchAtLoginService.shared.syncSystemState(enabled: launchAtLoginEnabled)
        }
    }

    @Published var animationsEnabled: Bool {
        didSet { defaults.set(animationsEnabled, forKey: Keys.animationsEnabled) }
    }

    @Published var soundEffectsEnabled: Bool {
        didSet { defaults.set(soundEffectsEnabled, forKey: Keys.soundEffectsEnabled) }
    }

    @Published var countdownVisible: Bool {
        didSet { defaults.set(countdownVisible, forKey: Keys.countdownVisible) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.launchAtLoginEnabled = defaults.object(forKey: Keys.launchAtLogin) as? Bool ?? false
        self.animationsEnabled = defaults.object(forKey: Keys.animationsEnabled) as? Bool ?? true
        self.soundEffectsEnabled = defaults.object(forKey: Keys.soundEffectsEnabled) as? Bool ?? false
        self.countdownVisible = defaults.object(forKey: Keys.countdownVisible) as? Bool ?? true
    }
}
