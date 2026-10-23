import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: SettingsStore
    private let positionStore = WindowPositionStore()

    var body: some View {
        Form {
            Section("Behavior") {
                Toggle("Launch at Login", isOn: $store.launchAtLoginEnabled)
                Toggle("Enable Animations", isOn: $store.animationsEnabled)
                Toggle("Sound Effects", isOn: $store.soundEffectsEnabled)
                Toggle("Show Countdown", isOn: $store.countdownVisible)
            }
            Section {
                Button("Reset Mascot Position") {
                    positionStore.reset()
                    NotificationCenter.default.post(name: .resetMascotPosition, object: nil)
                }
            }
        }
        .padding(20)
        .frame(width: 360, height: 300)
    }
}

#Preview {
    SettingsView(store: SettingsStore())
}
