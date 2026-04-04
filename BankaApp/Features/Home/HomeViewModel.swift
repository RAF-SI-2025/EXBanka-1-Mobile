import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var profile: ClientProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func loadProfile() async {
        guard let token = appState.accessToken else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let profile: ClientProfile = try await APIClient.shared.request(
                endpoint: .me,
                accessToken: token,
                deviceId: appState.deviceId
            )
            self.profile = profile
            appState.currentUser = profile
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
