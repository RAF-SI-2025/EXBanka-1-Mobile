import SwiftUI

struct TransactionsTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Payments").tag(0)
                    Text("Transfers").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppTheme.padding)
                .padding(.top, AppTheme.smallPadding)

                if selectedTab == 0 {
                    PaymentHistoryView()
                } else {
                    TransferHistoryView()
                }
            }
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.large)
    }
}
