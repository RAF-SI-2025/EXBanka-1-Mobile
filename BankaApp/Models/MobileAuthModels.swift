import Foundation

// POST /api/mobile/auth/request-activation
struct ActivationRequest: Encodable {
    let email: String
}

struct ActivationRequestResponse: Decodable {
    let success: Bool?
    let message: String
}

// POST /api/mobile/auth/activate
struct ActivateDeviceRequest: Encodable {
    let email: String
    let code: String
    let deviceName: String
}

struct ActivateDeviceResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let deviceId: String
    let deviceSecret: String
}

// POST /api/mobile/auth/refresh
struct MobileRefreshRequest: Encodable {
    let refreshToken: String
}

struct MobileRefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
