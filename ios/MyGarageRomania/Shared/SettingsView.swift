import SwiftUI
import UIKit
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var config: AppConfig
    @EnvironmentObject private var appState: AppState
    @StateObject private var notificationPermission = NotificationPermissionManager()
    @State private var connectionResult: ConnectionTestResult?
    @State private var isTestingConnection = false
    @State private var showClearLocalDataConfirmation = false
    @State private var passwordChangeMessage: String?
    @State private var testNotificationMessage: String?

    var body: some View {
        List {
            accountSection
            appearanceSection
            languageSection
            backendSection
            notificationsSection
        }
        .navigationTitle("Settings")
        .task {
            await appState.refreshCurrentUser()
            await notificationPermission.refresh()
        }
        .confirmationDialog("clear.local.data.title", isPresented: $showClearLocalDataConfirmation, titleVisibility: .visible) {
            Button("Clear Local Data", role: .destructive) {
                appState.clearLocalData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("clear.local.data.message")
        }
    }

    private var accountSection: some View {
        Section("Account") {
            LabeledContent("Display name") {
                Text(appState.currentUser?.displayName?.nilIfEmpty ?? String(localized: "account.unknown"))
                    .foregroundStyle(.secondary)
            }

            LabeledContent("Email") {
                Text(appState.currentUser?.email ?? String(localized: "account.unknown"))
                    .foregroundStyle(.secondary)
            }

            if let passwordChangeMessage {
                Label(passwordChangeMessage, systemImage: "checkmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.green)
            }

            NavigationLink {
                ChangePasswordView {
                    passwordChangeMessage = String(localized: "password.changed.title")
                }
            } label: {
                Label("Change Password", systemImage: "key.fill")
            }

            Button(role: .destructive) {
                appState.logout()
            } label: {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
            }

            Button(role: .destructive) {
                showClearLocalDataConfirmation = true
            } label: {
                Label("Clear Local Data", systemImage: "trash.fill")
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $config.theme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var languageSection: some View {
        Section {
            Picker("Language", selection: $config.language) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.displayName).tag(language)
                }
            }

            Text("language.restart.note")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } header: {
            Text("Language")
        }
    }

    private var backendSection: some View {
        Section("Backend / Developer") {
            LabeledContent("API Base URL") {
                Text(config.normalizedBaseURL.absoluteString)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }

            TextField("Base URL", text: $config.apiBaseURL)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                .autocorrectionDisabled()

            Button {
                Task { await testConnection() }
            } label: {
                if isTestingConnection {
                    ProgressView()
                } else {
                    Label("Test Connection", systemImage: "network")
                }
            }
            .disabled(isTestingConnection)

            if let connectionResult {
                Label(connectionResult.title, systemImage: iconName(for: connectionResult))
                    .foregroundStyle(color(for: connectionResult))
            }

            Button {
                config.resetBaseURL()
                connectionResult = nil
            } label: {
                Label("Use Default", systemImage: "arrow.counterclockwise")
            }

            #if DEBUG && targetEnvironment(simulator)
            Button {
                config.useLocalhostBaseURL()
                connectionResult = nil
            } label: {
                Label("Use Localhost", systemImage: "desktopcomputer")
            }
            #endif

            LabeledContent("Backend status") {
                Text(connectionResult?.title ?? String(localized: "backend.status.not_tested"))
                    .foregroundStyle(.secondary)
            }

            LabeledContent("App version") {
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            LabeledContent("Status") {
                Text(notificationStatusTitle)
                    .foregroundStyle(notificationStatusColor)
            }

            if notificationPermission.state == .notDetermined {
                Button {
                    Task { _ = await notificationPermission.requestPermission() }
                } label: {
                    Label("Enable Notifications", systemImage: "bell.badge.fill")
                }
            }

            if notificationPermission.state == .denied {
                Button {
                    openSystemSettings()
                } label: {
                    Label("Open iPhone Settings", systemImage: "gearshape.fill")
                }
            }

            #if DEBUG
            Button {
                Task { await scheduleTestNotification() }
            } label: {
                Label("Test Notification", systemImage: "bell.fill")
            }
            .disabled(!notificationPermission.canScheduleNotifications)

            if let testNotificationMessage {
                Text(testNotificationMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            #endif
        }
    }

    private var notificationStatusTitle: String {
        switch notificationPermission.state {
        case .authorized, .provisional:
            String(localized: "notifications.status.authorized")
        case .denied:
            String(localized: "notifications.status.denied")
        case .notDetermined:
            String(localized: "notifications.status.not_determined")
        case .unknown:
            String(localized: "notifications.status.unknown")
        }
    }

    private var notificationStatusColor: Color {
        switch notificationPermission.state {
        case .authorized, .provisional:
            .green
        case .denied:
            .red
        case .notDetermined, .unknown:
            .secondary
        }
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func testConnection() async {
        isTestingConnection = true
        defer { isTestingConnection = false }
        connectionResult = await appState.apiClient.testConnection()
    }

    private func iconName(for result: ConnectionTestResult) -> String {
        switch result {
        case .connected:
            "checkmark.circle.fill"
        case .unauthorizedReachable:
            "lock.circle.fill"
        case .cannotReachServer:
            "xmark.circle.fill"
        case .invalidURL:
            "exclamationmark.triangle.fill"
        }
    }

    private func color(for result: ConnectionTestResult) -> Color {
        switch result {
        case .connected:
            .green
        case .unauthorizedReachable:
            .orange
        case .cannotReachServer, .invalidURL:
            .red
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    #if DEBUG
    private func scheduleTestNotification() async {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notifications.test.title")
        content.body = String(localized: "notifications.test.body")
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "settings-test-\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            testNotificationMessage = String(localized: "notifications.test.scheduled")
        } catch {
            testNotificationMessage = error.localizedDescription
        }
    }
    #endif
}
