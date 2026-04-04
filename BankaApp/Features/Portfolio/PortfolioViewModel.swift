import Foundation
import Combine

@MainActor
final class PortfolioViewModel: ObservableObject {
    @Published var holdings: [Holding] = []
    @Published var summary: PortfolioSummary?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let appState: AppState

    init(appState: AppState = .shared) {
        self.appState = appState
    }

    func load() async {
        guard let token = appState.accessToken else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            async let holdingsReq: HoldingsResponse = APIClient.shared.request(
                endpoint: .myPortfolio,
                accessToken: token,
                deviceId: appState.deviceId
            )
            async let summaryReq: PortfolioSummary = APIClient.shared.request(
                endpoint: .myPortfolioSummary,
                accessToken: token,
                deviceId: appState.deviceId
            )
            let (h, s) = try await (holdingsReq, summaryReq)
            self.holdings = h.holdings
            self.summary = s
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
