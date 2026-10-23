import Foundation
import Combine

/// Drives animation playback for the whole hamster scene.
///
/// Deliberately timer-light: there is no per-frame display loop running at
/// all times. A frame-advance `Timer` only exists while a multi-frame state
/// is actually playing; blinking and ambient interactions use their own
/// long-interval timers (seconds apart, not frames apart). When animations
/// are disabled in Settings, every timer is torn down and the scene sits on
/// a single static idle frame.
final class HamsterSceneAnimator: ObservableObject {
    @Published private(set) var currentState: HamsterAnimationState = .idle
    @Published private(set) var frameIndex: Int = 0
    @Published private(set) var celinaEyesClosed = false
    @Published private(set) var kivancEyesClosed = false

    private var frameTimer: Timer?
    private var blinkTimer: Timer?
    private var ambientTimer: Timer?
    private var returnToIdleTimer: Timer?

    private(set) var animationsEnabled = true

    /// Ambient states the scene can drift into on its own, without a click.
    private let ambientStates: [HamsterAnimationState] = [.hugging, .missingYou, .celebration, .sleeping]
    /// States a click can trigger — the "random appropriate animation".
    private let clickableStates: [HamsterAnimationState] = [.excited, .hugging, .celebration]

    func start(animationsEnabled: Bool) {
        self.animationsEnabled = animationsEnabled
        guard animationsEnabled else {
            stop()
            return
        }
        scheduleBlinkTimer()
        scheduleAmbientTimer()
    }

    func setAnimationsEnabled(_ enabled: Bool) {
        animationsEnabled = enabled
        if enabled {
            scheduleBlinkTimer()
            scheduleAmbientTimer()
        } else {
            stop()
            currentState = .idle
            frameIndex = 0
        }
    }

    func stop() {
        frameTimer?.invalidate(); frameTimer = nil
        blinkTimer?.invalidate(); blinkTimer = nil
        ambientTimer?.invalidate(); ambientTimer = nil
        returnToIdleTimer?.invalidate(); returnToIdleTimer = nil
    }

    func enterSleepMode(_ sleeping: Bool) {
        guard animationsEnabled else { return }
        trigger(sleeping ? .sleeping : .idle)
    }

    /// A hamster was clicked: play a random appropriate reaction.
    func handleClick(on role: HamsterRole) {
        guard animationsEnabled, currentState == .idle else { return }
        trigger(clickableStates.randomElement() ?? .excited)
    }

    /// Plays the arrival-day celebration once, deterministically (not
    /// subject to the random ambient picker).
    func playArrivalCelebration() {
        trigger(.celebration)
    }

    private func trigger(_ state: HamsterAnimationState) {
        returnToIdleTimer?.invalidate()
        frameTimer?.invalidate()
        currentState = state
        frameIndex = 0

        guard state.isAnimated else { return }

        let frameCount = max(
            SpriteCatalog.pairSpec(for: state)?.frameCount ?? 1,
            1
        )
        let fps = SpriteCatalog.pairSpec(for: state)?.framesPerSecond ?? 8
        let timer = Timer(timeInterval: 1.0 / fps, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.frameIndex = (self.frameIndex + 1) % frameCount
        }
        RunLoop.main.add(timer, forMode: .common)
        frameTimer = timer

        if let duration = state.suggestedDuration {
            let returnTimer = Timer(timeInterval: duration, repeats: false) { [weak self] _ in
                self?.trigger(.idle)
            }
            RunLoop.main.add(returnTimer, forMode: .common)
            returnToIdleTimer = returnTimer
        }
    }

    private func scheduleBlinkTimer() {
        blinkTimer?.invalidate()
        let interval = Double.random(in: 3...8)
        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            self?.performBlink()
        }
        RunLoop.main.add(timer, forMode: .common)
        blinkTimer = timer
    }

    private func performBlink() {
        guard currentState == .idle else {
            scheduleBlinkTimer()
            return
        }
        let blinkCelina = Bool.random()
        if blinkCelina { celinaEyesClosed = true } else { kivancEyesClosed = true }
        let reopen = Timer(timeInterval: 0.18, repeats: false) { [weak self] _ in
            self?.celinaEyesClosed = false
            self?.kivancEyesClosed = false
            self?.scheduleBlinkTimer()
        }
        RunLoop.main.add(reopen, forMode: .common)
    }

    private func scheduleAmbientTimer() {
        ambientTimer?.invalidate()
        let interval = Double.random(in: 25...50)
        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            guard let self, self.currentState == .idle else {
                self?.scheduleAmbientTimer()
                return
            }
            self.trigger(self.ambientStates.randomElement() ?? .hugging)
            self.scheduleAmbientTimer()
        }
        RunLoop.main.add(timer, forMode: .common)
        ambientTimer = timer
    }
}
