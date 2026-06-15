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
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    let config = AppConfig()
    let keychain = KeychainStore()
    lazy var apiClient = ApiClient(config: config, keychain: keychain)

    @Published var isAuthenticated: Bool

    init() {
        isAuthenticated = ((try? keychain.readToken()) ?? nil) != nil
    }

    func completeLogin(token: String) throws {
        try keychain.saveToken(token)
        isAuthenticated = true
    }

    func logout() {
        try? keychain.clearToken()
        isAuthenticated = false
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
                Label("Garage", systemImage: "car.2.fill")
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
