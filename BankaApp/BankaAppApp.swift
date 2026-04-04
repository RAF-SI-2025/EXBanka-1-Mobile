import SwiftUI

@main
struct BankaAppApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var themeManager = ThemeManager.shared

    init() {
        let accessToken = KeychainService.loadAccessToken()
        let refreshToken = KeychainService.loadRefreshToken()
        let deviceId = KeychainService.loadDeviceId()

        guard let accessToken, let refreshToken, let deviceId else {
            Task { @MainActor in
                AppState.shared.authState = .notActivated
            }
            return
        }

        Task { @MainActor in
            AppState.shared.restoreSession(
                accessToken: accessToken,
                refreshToken: refreshToken,
                deviceId: deviceId
            )
            do {
                let profile: ClientProfile = try await APIClient.shared.request(
                    endpoint: .me,
                    accessToken: accessToken,
                    deviceId: deviceId
                )
                AppState.shared.currentUser = profile
            } catch APIError.unauthorized {
                do {
                    let refreshed = try await APIClient.shared.refreshTokens(
                        refreshToken: refreshToken,
                        deviceId: deviceId
                    )
                    AppState.shared.updateTokens(
                        accessToken: refreshed.accessToken,
                        refreshToken: refreshed.refreshToken
                    )
                    let profile: ClientProfile = try await APIClient.shared.request(
                        endpoint: .me,
                        accessToken: refreshed.accessToken,
                        deviceId: deviceId
                    )
                    AppState.shared.currentUser = profile
                } catch {
                    AppState.shared.logout()
                }
            } catch APIError.deviceDeactivated {
                AppState.shared.logout()
            } catch {
                // Network error on startup — keep session, user can retry
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        switch appState.authState {
        case .loading:
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ProgressView()
            }
        case .activated:
            MainTabView()
        case .notActivated:
            ActivationRequestView()
        }
    }
}
