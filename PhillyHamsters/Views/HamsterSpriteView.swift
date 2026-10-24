import SwiftUI
import AppKit

/// Renders one hamster for a *solo* state (idle / blinking / excited).
/// Uses Codex's sprite sheet if it has been added to the asset catalog;
/// otherwise falls back to the vector placeholder so the app always
/// renders something.
struct HamsterSpriteView: View {
    let role: HamsterRole
    let state: HamsterAnimationState
    let frameIndex: Int
    let eyesClosed: Bool
    let onTap: () -> Void

    var body: some View {
        content
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            .accessibilityLabel(Text("\(role == .celina ? "Celina" : "Kivanc") the hamster"))
            .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private var content: some View {
        if let spec = SpriteCatalog.soloSpec(for: role, state: eyesClosed && state == .idle ? .blinking : state),
           let sheet = NSImage(named: spec.assetName),
           let frame = sheet.spriteFrame(index: eyesClosed && state == .idle ? 2 : frameIndex % max(spec.frameCount, 1), frameCount: spec.frameCount) {
            Image(nsImage: frame)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 80, height: 80)
        } else {
            PlaceholderHamsterView(
                role: role,
                eyesClosed: eyesClosed,
                bounce: state == .excited
            )
        }
    }
}
