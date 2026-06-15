import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient: ApiClient
    private let appState: AppState

    init(apiClient: ApiClient, appState: AppState) {
        self.apiClient = apiClient
        self.appState = appState
    }

    func login() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Enter your email and password."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await apiClient.login(email: trimmedEmail, password: password)
            try appState.completeLogin(token: response.token)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
