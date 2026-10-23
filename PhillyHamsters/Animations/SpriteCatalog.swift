import AppKit

/// Describes one horizontal-strip sprite sheet: its asset name, how many
/// equal-width frames it contains, and the playback rate. This is the
/// contract between the animation engine and whatever art Codex drops into
/// the asset catalog — see DESIGN_HANDOFF.md for the authoritative list.
struct SpriteSheetSpec {
    let assetName: String
    let frameCount: Int
    let framesPerSecond: Double
}

enum SpriteCatalog {
    /// Solo sprite sheets: one hamster, independent of the other.
    static func soloSpec(for role: HamsterRole, state: HamsterAnimationState) -> SpriteSheetSpec? {
        switch state {
        case .idle:
            return SpriteSheetSpec(assetName: "\(role.rawValue)_idle", frameCount: 1, framesPerSecond: 1)
        case .blinking:
            return SpriteSheetSpec(assetName: "\(role.rawValue)_blink", frameCount: 4, framesPerSecond: 12)
        case .excited:
            return SpriteSheetSpec(assetName: "\(role.rawValue)_excited", frameCount: 6, framesPerSecond: 10)
        case .hugging, .missingYou, .sleeping, .celebration:
            // These are rendered as a single combined pair sheet instead.
            return nil
        }
    }

    /// Pair sprite sheets: both hamsters drawn together in one frame,
    /// used for the states where their relative position/pose matters.
    static func pairSpec(for state: HamsterAnimationState) -> SpriteSheetSpec? {
        switch state {
        case .hugging:
            return SpriteSheetSpec(assetName: "pair_hugging", frameCount: 8, framesPerSecond: 10)
        case .missingYou:
            return SpriteSheetSpec(assetName: "pair_missing_you", frameCount: 6, framesPerSecond: 8)
        case .sleeping:
            return SpriteSheetSpec(assetName: "pair_sleeping", frameCount: 2, framesPerSecond: 1)
        case .celebration:
            return SpriteSheetSpec(assetName: "pair_celebration", frameCount: 8, framesPerSecond: 10)
        case .idle, .blinking, .excited:
            return nil
        }
    }

    /// Whether Codex has dropped in real art for a given sheet name yet.
    /// Lets the view fall back to the vector placeholder per-sprite instead
    /// of all-or-nothing.
    static func hasArt(named assetName: String) -> Bool {
        NSImage(named: assetName) != nil
    }
}
