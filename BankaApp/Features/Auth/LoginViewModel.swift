import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response: LoginResponse = try await APIClient.shared.request(
                endpoint: .login,
                body: LoginRequest(email: email, password: password)
            )
            KeychainService.saveAccessToken(response.accessToken)
            KeychainService.saveRefreshToken(response.refreshToken)
            appState.restoreSession(accessToken: response.accessToken, refreshToken: response.refreshToken, deviceId: "")

            let profile: ClientProfile = try await APIClient.shared.request(
                endpoint: .me,
                accessToken: response.accessToken
            )
            appState.currentUser = profile
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
