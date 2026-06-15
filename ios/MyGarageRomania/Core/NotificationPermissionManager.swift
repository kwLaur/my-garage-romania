import Foundation
import UserNotifications

@MainActor
final class NotificationPermissionManager: ObservableObject {
    enum PermissionState: Equatable {
        case notDetermined
        case authorized
        case denied
        case provisional
        case unknown
    }

    @Published private(set) var state: PermissionState = .unknown

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func refresh() async {
        let settings = await center.notificationSettings()
        state = Self.map(settings.authorizationStatus)
    }

    func requestPermission() async -> PermissionState {
        do {
            _ = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            state = .denied
            return state
        }
        await refresh()
        return state
    }

    var canScheduleNotifications: Bool {
        state == .authorized || state == .provisional
    }

    private static func map(_ status: UNAuthorizationStatus) -> PermissionState {
        switch status {
        case .notDetermined:
            .notDetermined
        case .denied:
            .denied
        case .authorized:
            .authorized
        case .provisional:
            .provisional
        case .ephemeral:
            .authorized
        @unknown default:
            .unknown
        }
    }
}
