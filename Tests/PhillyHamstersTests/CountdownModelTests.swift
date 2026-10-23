import XCTest
@testable import PhillyHamsters

final class CountdownModelTests: XCTestCase {
    private let philadelphia = TimeZone(identifier: "America/New_York")!

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = philadelphia
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return calendar.date(from: components)!
    }

    func testFourteenDaysBeforeReunion() {
        let model = CountdownModel(now: date(2026, 10, 23))
        XCTAssertEqual(model.phase, .counting(daysRemaining: 14))
        XCTAssertEqual(model.countdownText, "14 days ♡")
    }

    func testOneDaySingularWording() {
        let model = CountdownModel(now: date(2026, 11, 5))
        XCTAssertEqual(model.phase, .counting(daysRemaining: 1))
        XCTAssertEqual(model.countdownText, "1 day ♡")
    }

    func testArrivalDayShowsHereText() {
        let model = CountdownModel(now: date(2026, 11, 6))
        XCTAssertEqual(model.phase, .arrivalDay)
        XCTAssertEqual(model.countdownText, "YOU'RE HERE!!!")
    }

    func testAfterArrivalStaysReunitedNotNegative() {
        let model = CountdownModel(now: date(2026, 11, 20))
        XCTAssertEqual(model.phase, .reunited)
        XCTAssertEqual(model.countdownText, "YOU'RE HERE!!!")
    }

    func testDateTransitionAtMidnightBoundary() {
        let model = CountdownModel(now: date(2026, 11, 5, hour: 23))
        XCTAssertEqual(model.phase, .counting(daysRemaining: 1))

        // Crossing midnight (America/New_York) should flip to arrival day,
        // independent of what time zone this test happens to run in.
        model.refresh(now: date(2026, 11, 6, hour: 0))
        XCTAssertEqual(model.phase, .arrivalDay)
    }

    func testUsesPhiladelphiaTimeZoneNotDeviceTimeZone() {
        // 11pm Philadelphia time on Nov 5 is already Nov 6 in UTC — the
        // model must follow Philadelphia, not UTC or the test machine's zone.
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!
        let novFifthLateEvening = date(2026, 11, 5, hour: 23)

        let model = CountdownModel(now: novFifthLateEvening)
        XCTAssertEqual(model.phase, .counting(daysRemaining: 1), "should still read Nov 5 in Philadelphia")
    }

    func testSecondsUntilNextMidnightIsPositiveAndUnderADay() {
        let seconds = CountdownModel.secondsUntilNextMidnight(after: date(2026, 10, 23, hour: 12))
        XCTAssertGreaterThan(seconds, 0)
        XCTAssertLessThanOrEqual(seconds, 24 * 60 * 60)
    }
}
