import Foundation
import Combine

@MainActor
final class AccountDetailViewModel: ObservableObject {
    @Published var payments: [Payment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let appState: AppState
    private let accountNumber: String

    init(appState: AppState, accountNumber: String) {
        self.appState = appState
        self.accountNumber = accountNumber
    }

    func loadTransactions() async {
        guard let token = appState.accessToken else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response: PaymentsResponse = try await APIClient.shared.request(
                endpoint: .paymentsForAccount(accountNumber: accountNumber),
                accessToken: token,
                deviceId: appState.deviceId
            )
            self.payments = response.payments
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
