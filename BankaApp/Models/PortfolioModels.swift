import Foundation

struct Holding: Decodable, Identifiable {
    let id: Int
    let securityType: String
    let ticker: String
    let name: String
    let quantity: Int
    let averagePrice: String
    let currentPrice: String
    let profit: String
    let publicQuantity: Int?
    let accountId: Int?
    let lastModified: String?
}

struct HoldingsResponse: Decodable {
    let holdings: [Holding]
    let totalCount: Int
}

struct PortfolioSummary: Decodable {
    let totalValue: String?
    let totalCost: String?
    let totalProfitLoss: String?
    let totalProfitLossPercent: String?
    let holdingsCount: Int?
}
