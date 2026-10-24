import SwiftUI

/// The entire contents of the floating panel: the countdown badge plus the
/// two hamsters. Fully transparent background — the panel itself has no
/// frame or chrome, so whatever isn't hamster/text here shows the desktop
/// straight through.
struct HamsterSceneView: View {
    @ObservedObject var countdownModel: CountdownModel
    @ObservedObject var settingsStore: SettingsStore
    @StateObject private var animator = HamsterSceneAnimator()

    @State private var hasCelebratedArrival = false
    @State private var isHovering = false

    private let pairStates: Set<HamsterAnimationState> = [.hugging, .missingYou, .sleeping, .celebration]

    var body: some View {
        VStack(spacing: 6) {
            if settingsStore.countdownVisible && animator.currentState != .sleeping {
                CountdownBadgeView(
                    countdownText: countdownModel.countdownText,
                    dailyMessage: countdownModel.dailyMessage,
                    showsMessage: isHovering || animator.currentState == .excited
                )
            }
            sceneBody
                .frame(width: 180, height: 90, alignment: .bottom)
                .onHover { isHovering = $0 }
        }
        .padding(8)
        .background(Color.clear)
        .onAppear {
            animator.start(animationsEnabled: settingsStore.animationsEnabled)
            celebrateIfArrivalDay()
        }
        .onChange(of: settingsStore.animationsEnabled) { enabled in
            animator.setAnimationsEnabled(enabled)
        }
        .onChange(of: countdownModel.phase) { _ in
            celebrateIfArrivalDay()
        }
    }

    @ViewBuilder
    private var sceneBody: some View {
        if pairStates.contains(animator.currentState) {
            PairSpriteView(
                state: animator.currentState,
                frameIndex: animator.frameIndex,
                onTap: { animator.handleClick(on: $0) }
            )
        } else {
            HStack(spacing: -4) {
                HamsterSpriteView(
                    role: .celina,
                    state: animator.currentState,
                    frameIndex: animator.frameIndex,
                    eyesClosed: animator.celinaEyesClosed,
                    onTap: { animator.handleClick(on: .celina) }
                )
                HamsterSpriteView(
                    role: .kivanc,
                    state: animator.currentState,
                    frameIndex: animator.frameIndex,
                    eyesClosed: animator.kivancEyesClosed,
                    onTap: { animator.handleClick(on: .kivanc) }
                )
            }
        }
    }

    private func celebrateIfArrivalDay() {
        guard countdownModel.phase == .arrivalDay, !hasCelebratedArrival else { return }
        hasCelebratedArrival = true
        animator.playArrivalCelebration()
    }
}
