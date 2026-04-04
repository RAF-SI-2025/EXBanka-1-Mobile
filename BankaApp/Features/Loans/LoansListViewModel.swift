import Foundation
import Combine

@MainActor
final class LoansListViewModel: ObservableObject {
    @Published var loans: [Loan] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let appState: AppState

    init(appState: AppState = .shared) {
        self.appState = appState
    }

    func loadLoans() async {
        guard let token = appState.accessToken else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response: LoansResponse = try await APIClient.shared.request(
                endpoint: .myLoans,
                accessToken: token,
                deviceId: appState.deviceId
            )
            self.loans = response.loans
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
