import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var config: AppConfig
    @EnvironmentObject private var appState: AppState
    @State private var connectionResult: ConnectionTestResult?
    @State private var isTestingConnection = false

    var body: some View {
        List {
            Section("API") {
                LabeledContent("API Base URL") {
                    Text(config.normalizedBaseURL.absoluteString)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }

                TextField("Base URL", text: $config.apiBaseURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()

                #if DEBUG
                Text("For simulator development, localhost points to the backend running on this Mac.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                #endif

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

                #if DEBUG
                Button {
                    config.useLocalhostBaseURL()
                    connectionResult = nil
                } label: {
                    Label("Use Localhost", systemImage: "arrow.counterclockwise")
                }
                #endif
            }

            Section("Session") {
                Button(role: .destructive) {
                    appState.logout()
                } label: {
                    Label("Logout and Clear Token", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Settings")
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
}
