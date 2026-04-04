import SwiftUI

struct SideMenuView: View {
    @Binding var isOpen: Bool
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.appPrimary)
                if let user = appState.currentUser {
                    Text(user.fullName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appForeground)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.appMutedForeground)
                }
            }
            .padding(AppTheme.largePadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appCard)

            Divider().background(Color.appBorder)

            VStack(spacing: 4) {
                NavigationLink(destination: VerificationView()) {
                    MenuRow(icon: "checkmark.shield.fill", label: "Verification")
                }
                .simultaneousGesture(TapGesture().onEnded { isOpen = false })

                NavigationLink(destination: DeviceInfoView()) {
                    MenuRow(icon: "iphone", label: "Device")
                }
                .simultaneousGesture(TapGesture().onEnded { isOpen = false })

                Button(action: { themeManager.toggle() }) {
                    MenuRow(
                        icon: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill",
                        label: themeManager.isDarkMode ? "Light Mode" : "Dark Mode"
                    )
                }

                Spacer()

                Divider().background(Color.appBorder)

                Button(action: {
                    Task { await logout() }
                }) {
                    MenuRow(icon: "rectangle.portrait.and.arrow.right", label: "Logout", isDestructive: true)
                }
                .padding(.bottom, AppTheme.largePadding)
            }
            .padding(.top, AppTheme.smallPadding)
        }
        .frame(width: 280)
        .background(Color.appBackground)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func logout() async {
        WebSocketManager.shared.disconnect()
        if let token = appState.accessToken, let deviceId = appState.deviceId {
            _ = try? await APIClient.shared.request(
                endpoint: .mobileDeviceDeactivate,
                accessToken: token,
                deviceId: deviceId
            ) as DeviceActionResponse
        }
        appState.logout()
        isOpen = false
    }
}

struct MenuRow: View {
    let icon: String
    let label: String
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: AppTheme.padding) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isDestructive ? .appDestructive : .appPrimary)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(isDestructive ? .appDestructive : .appForeground)
            Spacer()
        }
        .padding(.horizontal, AppTheme.largePadding)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
