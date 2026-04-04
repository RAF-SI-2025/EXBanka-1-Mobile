import Foundation

struct ExchangeRate: Decodable, Identifiable {
    var id: String { "\(fromCurrency)_\(toCurrency)" }
    let fromCurrency: String
    let toCurrency: String
    let buyRate: String
    let sellRate: String
    let updatedAt: String?
}

struct ExchangeRatesResponse: Decodable {
    let rates: [ExchangeRate]
}
