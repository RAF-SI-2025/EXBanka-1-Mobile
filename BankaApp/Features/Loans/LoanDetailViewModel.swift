import Foundation
import Combine

@MainActor
final class LoanDetailViewModel: ObservableObject {
    @Published var installments: [LoanInstallment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let appState: AppState
    let loanId: Int

    init(loanId: Int, appState: AppState = .shared) {
        self.loanId = loanId
        self.appState = appState
    }

    func loadInstallments() async {
        guard let token = appState.accessToken else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response: InstallmentsResponse = try await APIClient.shared.request(
                endpoint: .myLoanInstallments(loanId: loanId),
                accessToken: token,
                deviceId: appState.deviceId
            )
            self.installments = response.installments
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
