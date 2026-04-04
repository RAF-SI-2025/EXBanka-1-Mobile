import Foundation
import Combine

@MainActor
final class ExchangeRatesViewModel: ObservableObject {
    @Published var rates: [ExchangeRate] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func loadRates() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response: ExchangeRatesResponse = try await APIClient.shared.request(
                endpoint: .exchangeRates
            )
            self.rates = response.rates
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
