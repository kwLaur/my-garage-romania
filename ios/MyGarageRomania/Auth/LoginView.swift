import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: AuthViewModel
    @EnvironmentObject private var config: AppConfig

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header

                    AppleCard {
                        VStack(spacing: 18) {
                            TextField("Email", text: $viewModel.email)
                                .textContentType(.username)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .formTextField()

                            SecureField("Password", text: $viewModel.password)
                                .textContentType(.password)
                                .formTextField()

                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button {
                                Task { await viewModel.login() }
                            } label: {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text("Sign In")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .disabled(viewModel.isLoading)
                        }
                    }

                    AppleCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("API Server", systemImage: "network")
                                .font(.headline)
                            TextField("http://localhost:8080", text: $config.apiBaseURL)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .formTextField()
                            Text("Use your Mac LAN IP for a physical iPhone.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "car.side.fill")
                .font(.system(size: 46, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)

            Text("My Garage România")
                .font(.largeTitle.bold())

            Text("Your cars, receipts, documents, and maintenance in one private garage.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 36)
    }
}

private extension View {
    func formTextField() -> some View {
        self
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
