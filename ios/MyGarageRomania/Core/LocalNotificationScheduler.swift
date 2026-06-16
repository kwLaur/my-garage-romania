import Foundation
import UserNotifications

struct LocalNotificationScheduleInput {
    let entityType: NotificationPreferenceEntityType
    let entityId: UUID
    let vehicleName: String
    let itemName: String
    let dueDateString: String?
    let preference: NotificationPreference
}

final class LocalNotificationScheduler {
    private let center: UNUserNotificationCenter
    private let calendar: Calendar

    init(center: UNUserNotificationCenter = .current(), calendar: Calendar = .current) {
        self.center = center
        self.calendar = calendar
    }

    func reschedule(_ input: LocalNotificationScheduleInput) async {
        await cancel(entityType: input.entityType, entityId: input.entityId)
        guard
            input.preference.enabled,
            let dueDateString = input.dueDateString,
            let dueDate = Self.date(from: dueDateString, calendar: calendar)
        else {
            return
        }

        let reminderDays = input.preference.reminderDaysBefore.sorted(by: >)
        for daysBefore in reminderDays {
            await schedule(input: input, dueDate: dueDate, daysBefore: daysBefore, isDueDate: false)
        }
        if input.preference.notifyOnDueDate {
            await schedule(input: input, dueDate: dueDate, daysBefore: 0, isDueDate: true)
        }

        #if DEBUG
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix(entityType: input.entityType, entityId: input.entityId)) }.sorted()
        print("Pending notifications for \(input.entityId): \(ids)")
        #endif
    }

    func cancel(entityType: NotificationPreferenceEntityType, entityId: UUID) async {
        let prefix = identifierPrefix(entityType: entityType, entityId: entityId)
        let pending = await center.pendingNotificationRequests()
        let identifiers = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    static func triggerDate(dueDate: Date, daysBefore: Int, notificationTime: String, calendar: Calendar = .current) -> Date? {
        guard let reminderDate = calendar.date(byAdding: .day, value: -daysBefore, to: dueDate) else {
            return nil
        }
        let parts = notificationTime.split(separator: ":")
        guard
            parts.count == 2,
            parts[0].count == 2,
            parts[1].count == 2,
            let hour = Int(parts[0]),
            let minute = Int(parts[1]),
            (0...23).contains(hour),
            (0...59).contains(minute)
        else {
            return nil
        }

        var components = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components)
    }

    static func date(from value: String, calendar: Calendar = .current) -> Date? {
        var components = DateComponents()
        let parts = value.split(separator: "-")
        guard
            parts.count == 3,
            let year = Int(parts[0]),
            let month = Int(parts[1]),
            let day = Int(parts[2])
        else {
            return nil
        }
        components.calendar = calendar
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)
    }

    private func schedule(input: LocalNotificationScheduleInput, dueDate: Date, daysBefore: Int, isDueDate: Bool) async {
        guard
            let triggerDate = Self.triggerDate(dueDate: dueDate, daysBefore: daysBefore, notificationTime: input.preference.notificationTime, calendar: calendar),
            triggerDate > Date()
        else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title(input: input, daysBefore: daysBefore, isDueDate: isDueDate)
        content.body = body(input: input, daysBefore: daysBefore, isDueDate: isDueDate)
        content.sound = .default

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = notificationIdentifier(entityType: input.entityType, entityId: input.entityId, daysBefore: daysBefore, isDueDate: isDueDate)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await center.add(request)
    }

    private func title(input: LocalNotificationScheduleInput, daysBefore: Int, isDueDate: Bool) -> String {
        switch input.entityType {
        case .legalDocument:
            return isDueDate || daysBefore == 0 ? "\(input.itemName) expires today" : "\(input.itemName) expires soon"
        case .maintenance:
            return isDueDate || daysBefore == 0 ? "\(input.itemName) due today" : "\(input.itemName) due soon"
        }
    }

    private func body(input: LocalNotificationScheduleInput, daysBefore: Int, isDueDate: Bool) -> String {
        switch input.entityType {
        case .legalDocument:
            if isDueDate || daysBefore == 0 {
                return "\(input.vehicleName) \(input.itemName) expires today."
            }
            let unit = daysBefore == 1 ? "day" : "days"
            return "\(input.vehicleName) \(input.itemName) expires in \(daysBefore) \(unit)."
        case .maintenance:
            if isDueDate || daysBefore == 0 {
                return "\(input.vehicleName) \(input.itemName) is due today."
            }
            let unit = daysBefore == 1 ? "day" : "days"
            return "\(input.vehicleName) \(input.itemName) is due in \(daysBefore) \(unit)."
        }
    }

    private func notificationIdentifier(entityType: NotificationPreferenceEntityType, entityId: UUID, daysBefore: Int, isDueDate: Bool) -> String {
        if isDueDate {
            return "\(entityType.schedulerPrefix)-\(entityId.uuidString)-due"
        }
        return "\(entityType.schedulerPrefix)-\(entityId.uuidString)-\(daysBefore)"
    }

    private func identifierPrefix(entityType: NotificationPreferenceEntityType, entityId: UUID) -> String {
        "\(entityType.schedulerPrefix)-\(entityId.uuidString)-"
    }
}
