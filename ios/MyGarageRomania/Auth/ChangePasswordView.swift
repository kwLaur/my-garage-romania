import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    var onChanged: () -> Void = {}

    var body: some View {
        Form {
            Section {
                SecureField("Current password", text: $currentPassword)
                    .textContentType(.password)
                SecureField("New password", text: $newPassword)
                    .textContentType(.newPassword)
                SecureField("Confirm password", text: $confirmPassword)
                    .textContentType(.newPassword)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task { await changePassword() }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(isSaving)
            }
        }
        .navigationTitle("Change Password")
        .alert("password.changed.title", isPresented: $showSuccess) {
            Button("OK") {
                onChanged()
                dismiss()
            }
        } message: {
            Text("password.changed.message")
        }
    }

    private func changePassword() async {
        guard !currentPassword.isEmpty, !newPassword.isEmpty else {
            errorMessage = String(localized: "password.error.required")
            return
        }
        guard newPassword.count >= 8 else {
            errorMessage = String(localized: "auth.error.password_min")
            return
        }
        guard newPassword == confirmPassword else {
            errorMessage = String(localized: "auth.error.passwords_do_not_match")
            return
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await appState.apiClient.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
