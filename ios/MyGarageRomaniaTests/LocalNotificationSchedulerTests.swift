import XCTest
@testable import MyGarageRomania

final class LocalNotificationSchedulerTests: XCTestCase {
    func testTriggerDateUsesDueDateMinusDaysAndNotificationTime() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let dueDate = try XCTUnwrap(LocalNotificationScheduler.date(from: "2026-07-31", calendar: calendar))

        let triggerDate = try XCTUnwrap(LocalNotificationScheduler.triggerDate(dueDate: dueDate, daysBefore: 7, notificationTime: "09:30", calendar: calendar))
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)

        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 7)
        XCTAssertEqual(components.day, 24)
        XCTAssertEqual(components.hour, 9)
        XCTAssertEqual(components.minute, 30)
    }

    func testTriggerDateRejectsInvalidTime() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let dueDate = try XCTUnwrap(LocalNotificationScheduler.date(from: "2026-07-31", calendar: calendar))

        XCTAssertNil(LocalNotificationScheduler.triggerDate(dueDate: dueDate, daysBefore: 1, notificationTime: "9:00", calendar: calendar))
        XCTAssertNil(LocalNotificationScheduler.triggerDate(dueDate: dueDate, daysBefore: 1, notificationTime: "24:00", calendar: calendar))
    }
}
