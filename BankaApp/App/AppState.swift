import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    enum AuthState {
        case notActivated
        case activated
    }

    @Published var authState: AuthState = .notActivated
    @Published var currentUser: ClientProfile?
    @Published var accessToken: String?
    @Published var refreshToken: String?
    @Published var deviceId: String?

    static let shared = AppState()
    private init() {}

    var isActivated: Bool { authState == .activated }

    func activateDevice(
        accessToken: String,
        refreshToken: String,
        deviceId: String,
        deviceSecret: String
    ) {
        KeychainService.saveAccessToken(accessToken)
        KeychainService.saveRefreshToken(refreshToken)
        KeychainService.saveDeviceId(deviceId)
        KeychainService.saveDeviceSecret(deviceSecret)

        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.deviceId = deviceId
        self.authState = .activated
    }

    func updateTokens(accessToken: String, refreshToken: String) {
        KeychainService.saveAccessToken(accessToken)
        KeychainService.saveRefreshToken(refreshToken)
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func restoreSession(accessToken: String, refreshToken: String, deviceId: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.deviceId = deviceId
        self.authState = .activated
    }

    func logout() {
        KeychainService.deleteAll()
        self.accessToken = nil
        self.refreshToken = nil
        self.deviceId = nil
        self.currentUser = nil
        self.authState = .notActivated
    }
}
