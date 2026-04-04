import Foundation

struct Card: Decodable, Identifiable {
    let id: Int
    let cardNumber: String
    let cardType: String
    let cardName: String
    let brand: String
    let createdAt: String
    let expiresAt: String
    let accountNumber: String
    let cvv: String?
    let limit: Double?
    let status: String
    let ownerName: String?

    var maskedNumber: String {
        guard cardNumber.count >= 4 else { return cardNumber }
        let last4 = cardNumber.suffix(4)
        return "**** **** **** \(last4)"
    }

    var expiryFormatted: String {
        let iso = ISO8601DateFormatter()
        guard let date = iso.date(from: expiresAt) else { return expiresAt }
        let f = DateFormatter()
        f.dateFormat = "MM/yy"
        return f.string(from: date)
    }
}

struct CardsResponse: Decodable {
    let cards: [Card]
}
