import Foundation

struct Order: Decodable, Identifiable {
    let id: Int
    let listingId: Int?
    let holdingId: Int?
    let direction: String
    let orderType: String
    let status: String
    let quantity: Int
    let limitValue: String?
    let stopValue: String?
    let allOrNone: Bool?
    let margin: Bool?
    let accountId: Int?
    let ticker: String?
    let securityName: String?
    let createdAt: String?
    let updatedAt: String?

    var orderTypeLabel: String {
        switch orderType.lowercased() {
        case "market": return "Market"
        case "limit": return "Limit"
        case "stop": return "Stop"
        case "stop_limit": return "Stop Limit"
        default: return orderType
        }
    }
}

struct OrdersResponse: Decodable {
    let orders: [Order]
    let totalCount: Int
}
