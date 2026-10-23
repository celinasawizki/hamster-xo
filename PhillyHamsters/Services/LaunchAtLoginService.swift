import Foundation
import ServiceManagement

/// Thin wrapper around `SMAppService`, Apple's supported (non-deprecated)
/// API for registering a login item as of macOS 13. No helper tool, no
/// `LSSharedFileList` — just the main app registering/unregistering itself.
enum LaunchAtLoginService {
    static let shared = LaunchAtLoginServiceImpl()
}

final class LaunchAtLoginServiceImpl {
    /// Reflects the *actual* system registration state, which can drift
    /// from the UserDefaults toggle if the user removed the login item
    /// from System Settings directly.
    var isRegistered: Bool {
        SMAppService.mainApp.status == .enabled
    }

    func syncSystemState(enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            NSLog("PhillyHamsters: failed to update login item registration: \(error)")
        }
    }
}
