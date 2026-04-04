import Foundation
import Combine

@MainActor
final class DeviceInfoViewModel: ObservableObject {
    @Published var device: DeviceInfo?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var transferEmail: String = ""
    @Published var showTransferConfirm: Bool = false
    @Published var showDeactivateConfirm: Bool = false
    @Published var actionMessage: String?

    private let appState: AppState

    init(appState: AppState = .shared) {
        self.appState = appState
    }

    func loadDevice() async {
        guard let token = appState.accessToken,
              let deviceId = appState.deviceId else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            device = try await APIClient.shared.request(
                endpoint: .mobileDevice,
                accessToken: token,
                deviceId: deviceId
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deactivateDevice() async {
        guard let token = appState.accessToken,
              let deviceId = appState.deviceId else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let _: DeviceActionResponse = try await APIClient.shared.request(
                endpoint: .mobileDeviceDeactivate,
                accessToken: token,
                deviceId: deviceId
            )
            WebSocketManager.shared.disconnect()
            appState.logout()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func transferDevice() async {
        let email = transferEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else {
            errorMessage = "Please enter an email address."
            return
        }
        guard let token = appState.accessToken,
              let deviceId = appState.deviceId else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response: DeviceActionResponse = try await APIClient.shared.request(
                endpoint: .mobileDeviceTransfer,
                body: DeviceTransferRequest(email: email),
                accessToken: token,
                deviceId: deviceId
            )
            actionMessage = response.message ?? "Transfer initiated. A new activation code has been sent."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
