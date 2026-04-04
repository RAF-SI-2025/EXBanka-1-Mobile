import Foundation

struct DeviceInfo: Decodable {
    let deviceId: String
    let deviceName: String
    let status: String
    let activatedAt: String
    let lastSeenAt: String
}

struct DeviceTransferRequest: Encodable {
    let email: String
}

struct DeviceActionResponse: Decodable {
    let success: Bool?
    let message: String?
}
