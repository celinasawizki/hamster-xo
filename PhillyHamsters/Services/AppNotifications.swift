import Foundation

extension Notification.Name {
    /// Posted by the Settings window's "Reset Mascot Position" button, and
    /// by the menu bar's identical item, so either entry point snaps the
    /// live panel back to its default corner immediately.
    static let resetMascotPosition = Notification.Name("PhillyHamsters.resetMascotPosition")
}
