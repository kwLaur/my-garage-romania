import SwiftUI
import UIKit

struct NotificationSettingsTarget: Identifiable, Hashable {
    let vehicle: Vehicle
    let entityType: NotificationPreferenceEntityType
    let entityId: UUID
    let itemName: String
    let dueDateString: String?
    let initialPreference: NotificationPreference?

    var id: String {
        "\(entityType.rawValue)-\(entityId.uuidString)"
    }
}

struct NotificationSettingsView: View {
    let target: NotificationSettingsTarget
    let apiClient: ApiClient
    let onSaved: (NotificationPreference) -> Void
    let onDeleted: () -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var permissionManager = NotificationPermissionManager()
    @State private var draft: NotificationPreferenceDraft
    @State private var notificationDate: Date
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var statusMessage: String?
    @State private var errorMessage: String?

    private let scheduler = LocalNotificationScheduler()
    private let reminderOptions = [30, 14, 7, 1]

    init(target: NotificationSettingsTarget, apiClient: ApiClient, onSaved: @escaping (NotificationPreference) -> Void, onDeleted: @escaping () -> Void) {
        self.target = target
        self.apiClient = apiClient
        self.onSaved = onSaved
        self.onDeleted = onDeleted
        let draft = NotificationPreferenceDraft(preference: target.initialPreference)
        _draft = State(initialValue: draft)
        _notificationDate = State(initialValue: Self.date(from: draft.notificationTime))
    }

    var body: some View {
        Form {
            Section {
                Toggle("Enable notifications", isOn: $draft.enabled)
                    .font(.body.weight(.semibold))
                    .onChange(of: draft.enabled) { _, enabled in
                        guard enabled else { return }
                        Task {
                            await permissionManager.refresh()
                            if permissionManager.state == .notDetermined {
                                _ = await permissionManager.requestPermission()
                            }
                        }
                    }

                if permissionManager.state == .denied {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications are disabled for My Garage Romania. Enable notifications in iPhone Settings to receive reminders.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Button("Open Settings") {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                    }
                }

                if target.entityType == .maintenance && target.dueDateString == nil {
                    Text("This maintenance item has no date-based due date. Kilometer reminders stay visible in the app and are not scheduled as local notifications.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Reminder Days") {
                ForEach(reminderOptions, id: \.self) { days in
                    Button {
                        toggleDay(days)
                    } label: {
                        HStack {
                            Text("\(days) \(days == 1 ? "day" : "days") before")
                            Spacer()
                            if draft.selectedDays.contains(days) {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.semibold))
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
                Toggle("On due date", isOn: $draft.notifyOnDueDate)
            }
            .disabled(!draft.enabled)

            Section("Notification Time") {
                DatePicker("Time", selection: $notificationDate, displayedComponents: .hourAndMinute)
            }
            .disabled(!draft.enabled)

            Section {
                Button {
                    Task { await save() }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Label("Save reminder settings", systemImage: "bell.badge")
                    }
                }
                .disabled(isSaving || isLoading)

                Button(role: .destructive) {
                    Task { await disable() }
                } label: {
                    Label("Disable reminders", systemImage: "bell.slash")
                }
                .disabled(isSaving || isLoading)
            } footer: {
                Text("Notifications are scheduled on this iPhone. If you reinstall the app, open the vehicle again to reschedule reminders.")
            }

            if let statusMessage {
                Section {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
        .task {
            await load()
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        await permissionManager.refresh()
        do {
            if let preference = try await apiClient.fetchNotificationPreference(entityType: target.entityType, entityId: target.entityId) {
                draft = NotificationPreferenceDraft(preference: preference)
                notificationDate = Self.date(from: preference.notificationTime)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        statusMessage = nil
        defer { isSaving = false }

        draft.notificationTime = Self.timeString(from: notificationDate)
        if draft.enabled {
            await permissionManager.refresh()
            if permissionManager.state == .notDetermined {
                _ = await permissionManager.requestPermission()
            }
        }

        do {
            let preference = try await apiClient.saveNotificationPreference(
                entityType: target.entityType,
                entityId: target.entityId,
                request: draft.makeRequest(vehicleId: target.vehicle.id)
            )
            onSaved(preference)

            let scheduleInput = LocalNotificationScheduleInput(
                entityType: target.entityType,
                entityId: target.entityId,
                vehicleName: target.vehicle.name,
                itemName: target.itemName,
                dueDateString: target.dueDateString,
                preference: preference
            )
            if preference.enabled && permissionManager.canScheduleNotifications {
                await scheduler.reschedule(scheduleInput)
                statusMessage = "Reminder settings saved."
            } else {
                await scheduler.cancel(entityType: target.entityType, entityId: target.entityId)
                statusMessage = preference.enabled ? "Reminder settings saved, but notifications are disabled in iPhone Settings." : "Reminders are off."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func disable() async {
        isSaving = true
        errorMessage = nil
        statusMessage = nil
        defer { isSaving = false }

        do {
            try await apiClient.deleteNotificationPreference(entityType: target.entityType, entityId: target.entityId)
            await scheduler.cancel(entityType: target.entityType, entityId: target.entityId)
            onDeleted()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func toggleDay(_ days: Int) {
        if draft.selectedDays.contains(days) {
            draft.selectedDays.remove(days)
        } else {
            draft.selectedDays.insert(days)
        }
    }

    private static func date(from time: String) -> Date {
        let parts = time.split(separator: ":")
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = parts.count == 2 ? Int(parts[0]) ?? 9 : 9
        components.minute = parts.count == 2 ? Int(parts[1]) ?? 0 : 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private static func timeString(from date: Date) -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", components.hour ?? 9, components.minute ?? 0)
    }
}

struct NotificationSettingsSection: View {
    let target: NotificationSettingsTarget?
    let apiClient: ApiClient
    let summary: String
    let onSaved: (NotificationPreference) -> Void
    let onDeleted: () -> Void

    @State private var showingSettings = false

    var body: some View {
        Section("Reminders") {
            if target != nil {
                Button {
                    showingSettings = true
                } label: {
                    HStack {
                        Label(summary, systemImage: "bell.badge")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
            } else {
                Label("Save this item before configuring reminders", systemImage: "bell.slash")
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showingSettings) {
            if let target {
                NavigationStack {
                    NotificationSettingsView(target: target, apiClient: apiClient, onSaved: onSaved, onDeleted: onDeleted)
                }
            }
        }
    }
}

func notificationPreferenceSummary(_ preference: NotificationPreference?) -> String {
    guard let preference, preference.enabled else {
        return "Reminders off"
    }
    var parts = preference.reminderDaysBefore.sorted(by: >).map { "\($0)d" }
    if preference.notifyOnDueDate {
        parts.append("due day")
    }
    return parts.isEmpty ? "Reminders off" : "Reminders: \(parts.joined(separator: ", "))"
}

func legalReminderName(_ type: String) -> String {
    LegalDocumentType.displayName(type)
}
