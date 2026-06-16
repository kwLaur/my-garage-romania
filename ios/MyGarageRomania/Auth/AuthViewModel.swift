import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var displayName = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    let apiClient: ApiClient
    let appState: AppState

    init(apiClient: ApiClient, appState: AppState) {
        self.apiClient = apiClient
        self.appState = appState
    }

    func login() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = String(localized: "auth.error.email_password_required")
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await apiClient.login(email: trimmedEmail, password: password)
            try appState.completeLogin(token: response.token, user: response.user)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = String(localized: "auth.error.email_password_required")
            return
        }
        guard password.count >= 8 else {
            errorMessage = String(localized: "auth.error.password_min")
            return
        }
        guard password == confirmPassword else {
            errorMessage = String(localized: "auth.error.passwords_do_not_match")
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await apiClient.register(
                email: trimmedEmail,
                password: password,
                displayName: trimmedDisplayName.isEmpty ? nil : trimmedDisplayName
            )
            try appState.completeLogin(token: response.token, user: response.user)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
