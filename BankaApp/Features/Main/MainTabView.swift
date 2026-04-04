import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            NavigationStack {
                AccountsFullListView()
            }
            .tabItem {
                Image(systemName: "banknote.fill")
                Text("Accounts")
            }

            NavigationStack {
                CardsListView()
            }
            .tabItem {
                Image(systemName: "creditcard.fill")
                Text("Cards")
            }

            NavigationStack {
                TransactionsTabView()
            }
            .tabItem {
                Image(systemName: "clock.arrow.circlepath")
                Text("Transactions")
            }

            NavigationStack {
                MoreMenuView()
            }
            .tabItem {
                Image(systemName: "ellipsis.circle.fill")
                Text("More")
            }
        }
        .tint(.appPrimary)
    }
}
