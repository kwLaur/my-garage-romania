import SwiftUI

@main
struct MyGarageApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(appState.config)
                .tint(.blue)
                .preferredColorScheme(appState.config.theme.colorScheme)
                .task {
                    await appState.refreshCurrentUser()
                }
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    let config = AppConfig()
    let keychain = KeychainStore()
    lazy var apiClient = ApiClient(config: config, keychain: keychain)

    @Published var isAuthenticated: Bool
    @Published var currentUser: User?

    init() {
        config.applyLanguagePreference()
        isAuthenticated = ((try? keychain.readToken()) ?? nil) != nil
    }

    func completeLogin(token: String, user: User? = nil) throws {
        try keychain.saveToken(token)
        currentUser = user
        isAuthenticated = true
    }

    func logout() {
        try? keychain.clearToken()
        currentUser = nil
        isAuthenticated = false
    }

    func clearLocalData() {
        URLCache.shared.removeAllCachedResponses()
        logout()
    }

    func refreshCurrentUser() async {
        guard isAuthenticated else { return }
        do {
            currentUser = try await apiClient.fetchCurrentUser()
        } catch {
            currentUser = nil
        }
    }
}

private struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
            } else {
                LoginView(viewModel: AuthViewModel(apiClient: appState.apiClient, appState: appState))
            }
        }
    }
}

private struct MainTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            NavigationStack {
                VehicleListView(viewModel: VehicleViewModel(apiClient: appState.apiClient))
            }
            .tabItem {
                Label("Vehicles", systemImage: "car.2.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}
