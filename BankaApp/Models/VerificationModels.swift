import Foundation

enum VerificationMethod: String, Codable, CaseIterable {
    case codePull = "code_pull"
    case email = "email"
    case qrScan = "qr_scan"
    case numberMatch = "number_match"

    var displayName: String {
        switch self {
        case .codePull: return "Code"
        case .email: return "Email"
        case .qrScan: return "QR Scan"
        case .numberMatch: return "Number Match"
        }
    }

    var iconName: String {
        switch self {
        case .codePull: return "number.square"
        case .email: return "envelope.fill"
        case .qrScan: return "qrcode.viewfinder"
        case .numberMatch: return "hand.tap.fill"
        }
    }
}

struct PendingVerificationItem: Decodable, Identifiable {
    let id: Int
    let challengeId: Int
    let method: VerificationMethod
    let displayData: String
    let expiresAt: String

    var parsedDisplayData: VerificationDisplayData? {
        guard let data = displayData.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(VerificationDisplayData.self, from: data)
    }

    var expirationDate: Date? {
        ISO8601DateFormatter().date(from: expiresAt)
    }

    var isExpired: Bool {
        guard let date = expirationDate else { return true }
        return date < Date()
    }
}

struct VerificationDisplayData: Decodable {
    let code: String?
    let message: String?
    let options: [Int]?
}

struct PendingVerificationsResponse: Decodable {
    let items: [PendingVerificationItem]
}

// POST /api/mobile/verifications/:challenge_id/submit
struct VerificationSubmitRequest: Encodable {
    let response: String
}

struct VerificationSubmitResponse: Decodable {
    let success: Bool?
    let status: String?
    let remainingAttempts: Int?
}

// WebSocket message
struct WebSocketVerificationMessage: Decodable {
    let type: String
    let challengeId: Int
    let method: VerificationMethod
    let displayData: String
    let expiresAt: String

    func toPendingItem(id: Int = 0) -> PendingVerificationItem {
        PendingVerificationItem(
            id: id,
            challengeId: challengeId,
            method: method,
            displayData: displayData,
            expiresAt: expiresAt
        )
    }
}
