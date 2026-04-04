import Foundation

struct Transfer: Decodable, Identifiable {
    let id: Int
    let fromAccountNumber: String
    let toAccountNumber: String
    let initialAmount: Double
    let finalAmount: Double
    let exchangeRate: Double?
    let commission: Double?
    let timestamp: String
}

struct TransfersResponse: Decodable {
    let transfers: [Transfer]
    let total: Int
}
