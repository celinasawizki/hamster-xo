import Foundation

/// The hand-written daily message schedule from the design brief
/// (October 23 – November 6, 2026). Dates outside that explicit window fall
/// back to a generic playful message so the app never shows an empty label.
enum DailyMessages {
    /// Keyed by "M-d" in the America/New_York calendar.
    private static let schedule: [String: String] = [
        "10-23": "i miss you already",
        "10-24": "come to philly pls",
        "10-25": "still waiting…",
        "10-26": "i need a hug",
        "10-27": "10 more days!!!",
        "10-28": "hurry upppp",
        "10-29": "i miss you :(",
        "10-30": "ONE WEEK ONE WEEK",
        "10-31": "boo. miss you.",
        "11-1": "FIVE DAYS!!!!!",
        "11-2": "almost almost almost",
        "11-3": "THREE THREE THREE",
        "11-4": "TWO MORE SLEEPS",
        "11-5": "TOMORROW TOMORROW TOMORROW",
        "11-6": "YOU'RE HERE YOU'RE HERE!!!"
    ]

    static func message(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.month, .day], from: date)
        guard let month = components.month, let day = components.day else {
            return "counting down to philly ♡"
        }
        let key = "\(month)-\(day)"
        if let message = schedule[key] {
            return message
        }
        // Outside the scheduled window: before Oct 23 keep it generic;
        // after Nov 6 stay in the reunited mood.
        let reunionStart = calendar.startOfDay(for: CountdownModel.reunionDate)
        return date >= reunionStart ? "together in philly ♡" : "counting down to philly ♡"
    }
}
