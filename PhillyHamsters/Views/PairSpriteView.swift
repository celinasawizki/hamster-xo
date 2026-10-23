import SwiftUI
import AppKit

/// Renders both hamsters together for states where their relative pose
/// matters (hugging, missing-you, sleeping, celebration). Same art-or-
/// placeholder fallback pattern as `HamsterSpriteView`.
struct PairSpriteView: View {
    let state: HamsterAnimationState
    let frameIndex: Int
    let onTap: (HamsterRole) -> Void

    var body: some View {
        content
            .frame(width: 180, height: 90)
    }

    @ViewBuilder
    private var content: some View {
        if let spec = SpriteCatalog.pairSpec(for: state),
           let sheet = NSImage(named: spec.assetName),
           let frame = sheet.spriteFrame(index: frameIndex % max(spec.frameCount, 1), frameCount: spec.frameCount) {
            Image(nsImage: frame)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
        } else {
            placeholderPair
        }
    }

    private var placeholderPair: some View {
        ZStack {
            HStack(spacing: horizontalSpacing) {
                PlaceholderHamsterView(role: .celina, sad: state == .missingYou)
                    .onTapGesture { onTap(.celina) }
                PlaceholderHamsterView(role: .kivanc)
                    .onTapGesture { onTap(.kivanc) }
            }
            if state == .hugging || state == .celebration {
                Text("♡")
                    .font(.system(size: 18))
                    .foregroundStyle(.pink)
                    .offset(y: -36)
                    .opacity(heartOpacity)
            }
            if state == .sleeping {
                Text("z z z")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .offset(x: 50, y: -30)
            }
        }
    }

    private var horizontalSpacing: CGFloat {
        switch state {
        case .hugging, .sleeping: return -18
        case .celebration: return 4
        default: return 10
        }
    }

    private var heartOpacity: Double {
        // Simple pulse keyed off the shared frame counter, without a
        // second timer: alternate visibility across frame parity.
        frameIndex % 2 == 0 ? 1.0 : 0.6
    }
}
