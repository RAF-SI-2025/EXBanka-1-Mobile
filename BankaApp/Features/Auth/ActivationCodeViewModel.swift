import Foundation
import Combine
import UIKit

@MainActor
final class ActivationCodeViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let email: String
    private let appState: AppState

    init(email: String, appState: AppState = .shared) {
        self.email = email
        self.appState = appState
    }

    func activate() async {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedCode.count == 6 else {
            errorMessage = "Please enter the 6-digit code."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let deviceName = await UIDevice.current.name
            let response: ActivateDeviceResponse = try await APIClient.shared.request(
                endpoint: .mobileActivate,
                body: ActivateDeviceRequest(
                    email: email,
                    code: trimmedCode,
                    deviceName: deviceName
                )
            )
            appState.activateDevice(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                deviceId: response.deviceId,
                deviceSecret: response.deviceSecret
            )
            let profile: ClientProfile = try await APIClient.shared.request(
                endpoint: .me,
                accessToken: response.accessToken,
                deviceId: response.deviceId
            )
            appState.currentUser = profile
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
