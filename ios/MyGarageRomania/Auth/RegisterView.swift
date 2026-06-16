import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel: AuthViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create account")
                        .font(.largeTitle.bold())
                    Text("register.subtitle")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)

                AppleCard {
                    VStack(spacing: 18) {
                        TextField("Display name", text: $viewModel.displayName)
                            .textContentType(.name)
                            .formTextField()

                        TextField("Email", text: $viewModel.email)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .formTextField()

                        SecureField("Password", text: $viewModel.password)
                            .textContentType(.newPassword)
                            .formTextField()

                        SecureField("Confirm password", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .formTextField()

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            Task { await viewModel.register() }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                }
                                Text("Create account")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(viewModel.isLoading)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
    }
}
