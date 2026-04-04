import Foundation
import Combine

@MainActor
final class CardsListViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let appState: AppState

    init(appState: AppState = .shared) {
        self.appState = appState
    }

    func loadCards() async {
        guard let token = appState.accessToken else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response: CardsResponse = try await APIClient.shared.request(
                endpoint: .myCards,
                accessToken: token,
                deviceId: appState.deviceId
            )
            self.cards = response.cards
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
