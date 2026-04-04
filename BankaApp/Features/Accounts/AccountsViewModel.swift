import Foundation
import Combine

@MainActor
final class AccountsViewModel: ObservableObject {
    @Published var accounts: [BankAccount] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func loadAccounts() async {
        guard let token = appState.accessToken else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response: AccountsResponse = try await APIClient.shared.request(
                endpoint: .myAccounts,
                accessToken: token,
                deviceId: appState.deviceId
            )
            self.accounts = response.accounts
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
