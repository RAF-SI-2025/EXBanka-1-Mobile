import SwiftUI

struct ActivationRequestView: View {
    @StateObject private var viewModel = ActivationRequestViewModel()
    @State private var navigateToCode = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: AppTheme.smallPadding) {
                        Image(systemName: "iphone.and.arrow.forward")
                            .font(.system(size: 52))
                            .foregroundColor(.appPrimary)
                        Text("Activate Device")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.appForeground)
                        Text("Enter your email to receive an activation code")
                            .font(.subheadline)
                            .foregroundColor(.appMutedForeground)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, AppTheme.largePadding * 2)

                    VStack(spacing: AppTheme.padding) {
                        BankaTextField(title: "Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.appDestructive)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button(action: {
                            Task { await viewModel.requestActivation() }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .appPrimaryForeground))
                                    .frame(maxWidth: .infinity, minHeight: 48)
                            } else {
                                Text("Send Activation Code")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.appPrimaryForeground)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                            }
                        }
                        .background(Color.appPrimary)
                        .cornerRadius(AppTheme.cornerRadius)
                        .disabled(viewModel.isLoading)
                    }
                    .padding(AppTheme.largePadding)
                    .background(Color.appCard)
                    .cornerRadius(AppTheme.cornerRadius * 1.4)
                    .shadow(color: Color.appForeground.opacity(0.08), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, AppTheme.padding)

                    Spacer()
                }
            }
            .onChange(of: viewModel.codeSent) { _, sent in
                if sent { navigateToCode = true }
            }
            .navigationDestination(isPresented: $navigateToCode) {
                ActivationCodeView(email: viewModel.email)
            }
        }
    }
}
