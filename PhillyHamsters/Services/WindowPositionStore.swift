import Foundation
import CoreGraphics

/// Persists the panel's top-left origin across launches. Position is stored
/// relative to the bottom-right corner of the screen it was last placed on,
/// so it stays sane across resolution changes and multi-monitor setups
/// rather than replaying an absolute, possibly now off-screen, coordinate.
struct WindowPositionStore {
    private static let insetFromBottomRightKey = "hamsterPanelInsetFromBottomRight"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Default resting spot: tucked into the bottom-right corner.
    static let defaultInset = CGSize(width: 220, height: 180)

    func savedInsetFromBottomRight() -> CGSize? {
        guard let dict = defaults.dictionary(forKey: Self.insetFromBottomRightKey),
              let width = dict["width"] as? Double,
              let height = dict["height"] as? Double else {
            return nil
        }
        return CGSize(width: width, height: height)
    }

    func save(insetFromBottomRight inset: CGSize) {
        defaults.set(["width": inset.width, "height": inset.height], forKey: Self.insetFromBottomRightKey)
    }

    func reset() {
        defaults.removeObject(forKey: Self.insetFromBottomRightKey)
    }
}
