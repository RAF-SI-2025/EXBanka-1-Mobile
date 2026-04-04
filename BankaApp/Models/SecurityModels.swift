import Foundation

struct Stock: Decodable, Identifiable {
    let id: Int
    let ticker: String
    let name: String
    let outstandingShares: Int?
    let dividendYield: Double?
    let exchangeAcronym: String?
    let price: String
    let ask: String?
    let bid: String?
    let change: String?
    let volume: Int?
    let lastRefresh: String?
    let marketCap: String?
    let maintenanceMargin: String?
    let initialMarginCost: String?
}

struct StocksResponse: Decodable {
    let stocks: [Stock]
    let totalCount: Int
}

struct FuturesContract: Decodable, Identifiable {
    let id: Int
    let ticker: String
    let name: String
    let contractSize: Int?
    let contractUnit: String?
    let settlementDate: String?
    let exchangeAcronym: String?
    let price: String
    let ask: String?
    let bid: String?
    let change: String?
    let volume: Int?
    let lastRefresh: String?
    let maintenanceMargin: String?
    let initialMarginCost: String?
}

struct FuturesResponse: Decodable {
    let futures: [FuturesContract]
    let totalCount: Int
}

struct ForexPair: Decodable, Identifiable {
    let id: Int
    let ticker: String
    let name: String
    let baseCurrency: String?
    let quoteCurrency: String?
    let exchangeRate: String?
    let liquidity: String?
    let price: String
    let ask: String?
    let bid: String?
    let change: String?
    let volume: Int?
    let lastRefresh: String?
    let maintenanceMargin: String?
    let initialMarginCost: String?
}

struct ForexResponse: Decodable {
    let forexPairs: [ForexPair]
    let totalCount: Int
}
