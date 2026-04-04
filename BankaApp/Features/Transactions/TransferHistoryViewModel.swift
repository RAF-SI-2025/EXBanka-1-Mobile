import Foundation
import Combine

@MainActor
final class TransferHistoryViewModel: ObservableObject {
    @Published var transfers: [Transfer] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let appState: AppState

    init(appState: AppState = .shared) {
        self.appState = appState
    }

    func loadTransfers() async {
        guard let token = appState.accessToken else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response: TransfersResponse = try await APIClient.shared.request(
                endpoint: .myTransfers,
                accessToken: token,
                deviceId: appState.deviceId
            )
            self.transfers = response.transfers
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
