import XCTest
@testable import PhillyHamsters

final class DailyMessagesTests: XCTestCase {
    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func testEachScheduledDateMatchesTheBrief() {
        let expected: [(Int, Int, String)] = [
            (10, 23, "i miss you already"),
            (10, 24, "come to philly pls"),
            (10, 25, "still waiting…"),
            (10, 26, "i need a hug"),
            (10, 27, "10 more days!!!"),
            (10, 28, "hurry upppp"),
            (10, 29, "i miss you :("),
            (10, 30, "ONE WEEK ONE WEEK"),
            (10, 31, "boo. miss you."),
            (11, 1, "FIVE DAYS!!!!!"),
            (11, 2, "almost almost almost"),
            (11, 3, "THREE THREE THREE"),
            (11, 4, "TWO MORE SLEEPS"),
            (11, 5, "TOMORROW TOMORROW TOMORROW"),
            (11, 6, "YOU'RE HERE YOU'RE HERE!!!")
        ]
        for (month, day, message) in expected {
            let result = DailyMessages.message(for: date(2026, month, day), calendar: calendar)
            XCTAssertEqual(result, message, "mismatch for \(month)/\(day)")
        }
    }

    func testFallsBackBeforeScheduledWindow() {
        let result = DailyMessages.message(for: date(2026, 9, 1), calendar: calendar)
        XCTAssertEqual(result, "counting down to philly ♡")
    }

    func testFallsBackAfterScheduledWindow() {
        let result = DailyMessages.message(for: date(2026, 12, 25), calendar: calendar)
        XCTAssertEqual(result, "together in philly ♡")
    }
}
