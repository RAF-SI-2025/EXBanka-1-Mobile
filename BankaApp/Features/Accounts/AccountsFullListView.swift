import SwiftUI

struct AccountsFullListView: View {
    @StateObject private var viewModel = AccountsViewModel(appState: AppState.shared)

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: AppTheme.padding) {
                    Text(error).font(.caption).foregroundColor(.appDestructive)
                    Button("Retry") { Task { await viewModel.loadAccounts() } }
                        .foregroundColor(.appPrimary)
                }
            } else if viewModel.accounts.isEmpty {
                Text("No accounts found.")
                    .font(.subheadline)
                    .foregroundColor(.appMutedForeground)
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.smallPadding) {
                        ForEach(viewModel.accounts) { account in
                            NavigationLink(destination: AccountDetailView(account: account)) {
                                AccountRowView(account: account)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
        }
        .navigationTitle("Accounts")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.loadAccounts() }
    }
}
