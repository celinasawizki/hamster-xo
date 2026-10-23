import Foundation

/// The seven required animation states, shared by both hamsters. Not every
/// state is symmetric (e.g. in `.missingYou` one hamster is sad and the
/// other comforts them) — `HamsterRole` disambiguates which half of the
/// pair a given view is rendering.
enum HamsterAnimationState: String, CaseIterable {
    case idle
    case blinking
    case excited
    case hugging
    case missingYou
    case sleeping
    case celebration

    /// Whether this state cycles through multiple frames (and therefore
    /// needs the frame timer running) or is effectively a single still pose.
    var isAnimated: Bool {
        switch self {
        case .idle: return false
        case .blinking, .excited, .hugging, .missingYou, .sleeping, .celebration: return true
        }
    }

    /// Roughly how long a one-shot playback of this state should last
    /// before the scene falls back to idle. `.idle` is the resting state,
    /// so it has no natural end; `.sleeping` is a nap, not forever.
    var suggestedDuration: TimeInterval? {
        switch self {
        case .idle: return nil
        case .blinking: return 0.3
        case .excited: return 1.6
        case .hugging: return 2.4
        case .missingYou: return 2.0
        case .sleeping: return 6.0
        case .celebration: return 2.2
        }
    }
}

enum HamsterRole: String {
    case celina
    case kivanc
}
