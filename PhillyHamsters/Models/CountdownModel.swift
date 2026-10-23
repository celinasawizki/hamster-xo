import Foundation
import Combine

/// Where the countdown is relative to the reunion date.
enum CountdownPhase: Equatable {
    case counting(daysRemaining: Int)
    case arrivalDay
    case reunited
}

/// Computes the days remaining until the reunion date and the matching
/// daily message. All date math happens in `America/New_York`, never the
/// device's local time zone, per the spec: Kivanc's Mac could be set to any
/// time zone and the countdown must still read "Philadelphia time".
final class CountdownModel: ObservableObject {
    static let philadelphiaTimeZone = TimeZone(identifier: "America/New_York")!

    /// November 6, 2026, midnight, in America/New_York.
    static let reunionDate: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 6
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = philadelphiaTimeZone
        return calendar.date(from: components)!
    }()

    @Published private(set) var phase: CountdownPhase = .counting(daysRemaining: 0)
    @Published private(set) var dailyMessage: String = ""

    /// Short label for the countdown badge, e.g. "14 days ♡", "1 day ♡",
    /// or "YOU'RE HERE!!!" on arrival day. Stays on the arrival text after
    /// the reunion date too, rather than ever showing a negative count.
    var countdownText: String {
        switch phase {
        case .counting(let days):
            return days == 1 ? "1 day ♡" : "\(days) days ♡"
        case .arrivalDay, .reunited:
            return "YOU'RE HERE!!!"
        }
    }

    init(now: Date = Date()) {
        refresh(now: now)
    }

    /// Recomputes `phase` and `dailyMessage` for `now`. Cheap enough to call
    /// on every wake/midnight/active-app tick; does no I/O and allocates
    /// nothing beyond a couple of `DateComponents`.
    func refresh(now: Date = Date()) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = Self.philadelphiaTimeZone

        let todayStart = calendar.startOfDay(for: now)
        let reunionStart = calendar.startOfDay(for: Self.reunionDate)

        let daysUntil = calendar.dateComponents([.day], from: todayStart, to: reunionStart).day ?? 0

        if daysUntil > 0 {
            phase = .counting(daysRemaining: daysUntil)
        } else if daysUntil == 0 {
            phase = .arrivalDay
        } else {
            phase = .reunited
        }

        dailyMessage = DailyMessages.message(for: todayStart, calendar: calendar)
    }

    /// Seconds from `now` until the next local midnight in Philadelphia,
    /// used to schedule the next recompute without a per-second timer.
    static func secondsUntilNextMidnight(after now: Date) -> TimeInterval {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = philadelphiaTimeZone
        let todayStart = calendar.startOfDay(for: now)
        guard let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart) else {
            return 60 * 60
        }
        return tomorrowStart.timeIntervalSince(now)
    }
}
