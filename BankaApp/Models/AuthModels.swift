import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct LogoutRequest: Encodable {
    let refreshToken: String
}

struct MessageResponse: Decodable {
    let message: String
}

struct RefreshRequest: Encodable {
    let refreshToken: String
}

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
