import SwiftUI

struct MoreMenuView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // User header
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
                    .cornerRadius(AppTheme.cornerRadius)
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.bottom, AppTheme.padding)

                    VStack(spacing: 2) {
                        MoreMenuSection(title: "Banking") {
                            MoreMenuLink(icon: "building.columns.fill", label: "Loans", destination: LoansListView())
                            MoreMenuLink(icon: "chart.line.uptrend.xyaxis", label: "Exchange Rates", destination: ExchangeRatesView())
                        }

                        MoreMenuSection(title: "Investing") {
                            MoreMenuLink(icon: "chart.pie.fill", label: "Portfolio", destination: PortfolioView())
                        }

                        MoreMenuSection(title: "Security") {
                            MoreMenuLink(icon: "checkmark.shield.fill", label: "Verification", destination: VerificationView())
                            MoreMenuLink(icon: "iphone", label: "Device", destination: DeviceInfoView())
                        }

                        MoreMenuSection(title: "Settings") {
                            Button(action: { themeManager.toggle() }) {
                                MoreMenuRow(
                                    icon: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill",
                                    label: themeManager.isDarkMode ? "Light Mode" : "Dark Mode"
                                )
                            }
                        }

                        Button(action: { Task { await logout() } }) {
                            MoreMenuRow(icon: "rectangle.portrait.and.arrow.right", label: "Logout", isDestructive: true)
                        }
                        .padding(.top, AppTheme.padding)
                    }
                    .padding(.horizontal, AppTheme.padding)
                }
                .padding(.top, AppTheme.padding)
            }
        }
        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.large)
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
    }
}

struct MoreMenuSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.appMutedForeground)
                .padding(.horizontal, AppTheme.padding)
                .padding(.top, AppTheme.padding)
                .padding(.bottom, AppTheme.smallPadding)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.appCard)
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
}

struct MoreMenuLink<Destination: View>: View {
    let icon: String
    let label: String
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            MoreMenuRow(icon: icon, label: label)
        }
    }
}

struct MoreMenuRow: View {
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
            if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.appMutedForeground)
            }
        }
        .padding(.horizontal, AppTheme.padding)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
