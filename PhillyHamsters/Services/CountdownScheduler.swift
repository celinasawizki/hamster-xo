import Foundation
import AppKit

/// Keeps `CountdownModel` correct over time without a per-second timer.
/// A single `Timer` is scheduled for the next Philadelphia midnight; it
/// reschedules itself each time it fires. Sleep/wake and clock changes are
/// handled separately because a sleeping Mac does not fire timers, so on
/// wake the scheduled timer may be long past due — we just recompute and
/// reschedule immediately rather than trusting the stale timer.
final class CountdownScheduler {
    private let model: CountdownModel
    private var midnightTimer: Timer?
    private var observers: [NSObjectProtocol] = []

    init(model: CountdownModel) {
        self.model = model
    }

    func start() {
        refreshAndReschedule()

        let center = NSWorkspace.shared.notificationCenter
        observers.append(center.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            self?.refreshAndReschedule()
        })

        observers.append(NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSSystemClockDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            self?.refreshAndReschedule()
        })

        observers.append(NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            self?.model.refresh()
        })
    }

    func stop() {
        midnightTimer?.invalidate()
        midnightTimer = nil
        let defaultCenter = NotificationCenter.default
        let workspaceCenter = NSWorkspace.shared.notificationCenter
        for observer in observers {
            defaultCenter.removeObserver(observer)
            workspaceCenter.removeObserver(observer)
        }
        observers.removeAll()
    }

    private func refreshAndReschedule() {
        model.refresh()

        midnightTimer?.invalidate()
        let interval = max(1, CountdownModel.secondsUntilNextMidnight(after: Date()))
        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            self?.refreshAndReschedule()
        }
        // .common so it still fires while a menu/panel drag loop is tracking.
        RunLoop.main.add(timer, forMode: .common)
        midnightTimer = timer
    }
}
