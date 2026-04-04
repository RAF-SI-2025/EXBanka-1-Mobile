import Foundation
import Combine

@MainActor
final class PaymentHistoryViewModel: ObservableObject {
    @Published var payments: [Payment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let appState: AppState

    init(appState: AppState = .shared) {
        self.appState = appState
    }

    func loadPayments() async {
        guard let token = appState.accessToken else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response: PaymentsResponse = try await APIClient.shared.request(
                endpoint: .myPayments,
                accessToken: token,
                deviceId: appState.deviceId
            )
            self.payments = response.payments
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
