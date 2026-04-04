import SwiftUI

struct ActivationCodeView: View {
    let email: String
    @StateObject private var viewModel: ActivationCodeViewModel

    init(email: String) {
        self.email = email
        _viewModel = StateObject(wrappedValue: ActivationCodeViewModel(email: email))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: AppTheme.smallPadding) {
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 52))
                        .foregroundColor(.appPrimary)
                    Text("Enter Code")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.appForeground)
                    Text("We sent a 6-digit code to\n\(email)")
                        .font(.subheadline)
                        .foregroundColor(.appMutedForeground)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, AppTheme.largePadding * 2)

                VStack(spacing: AppTheme.padding) {
                    BankaTextField(title: "Activation Code", text: $viewModel.code)
                        .keyboardType(.numberPad)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.appDestructive)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: {
                        Task { await viewModel.activate() }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .appPrimaryForeground))
                                .frame(maxWidth: .infinity, minHeight: 48)
                        } else {
                            Text("Activate")
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
        .navigationBarTitleDisplayMode(.inline)
    }
}
