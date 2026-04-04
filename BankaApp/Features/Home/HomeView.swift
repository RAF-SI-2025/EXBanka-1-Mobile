import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var wsManager = WebSocketManager.shared

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel(appState: AppState.shared))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.padding) {
                    WelcomeCard(
                        profile: viewModel.profile,
                        isLoading: viewModel.isLoading,
                        errorMessage: viewModel.errorMessage
                    )

                    AccountsListView()
                }
                .padding(AppTheme.padding)
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadProfile() }
        .onAppear {
            if let token = AppState.shared.accessToken,
               let deviceId = AppState.shared.deviceId {
                wsManager.connect(accessToken: token, deviceId: deviceId)
            }
        }
    }
}

struct WelcomeCard: View {
    let profile: ClientProfile?
    let isLoading: Bool
    let errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.smallPadding) {
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Loading profile…")
                        .font(.subheadline)
                        .foregroundColor(.appMutedForeground)
                }
            } else if let profile {
                Text("Welcome, \(profile.firstName)!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.appForeground)

                Divider().background(Color.appBorder).padding(.vertical, 4)

                LabeledRow(label: "First Name", value: profile.firstName)
                LabeledRow(label: "Last Name", value: profile.lastName)
                LabeledRow(label: "Email", value: profile.email)
            } else {
                Text("Welcome!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.appForeground)

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.appDestructive)
                        .padding(.top, 2)
                }

            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.padding)
        .background(Color.appCard)
        .cornerRadius(AppTheme.cornerRadius * 1.4)
        .shadow(color: Color.appForeground.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

struct LabeledRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.appMutedForeground)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.appForeground)
        }
    }
}
