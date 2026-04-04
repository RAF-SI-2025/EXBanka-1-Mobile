import SwiftUI

struct PaymentHistoryView: View {
    @StateObject private var viewModel = PaymentHistoryViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: AppTheme.padding) {
                    Text(error).font(.caption).foregroundColor(.appDestructive)
                    Button("Retry") { Task { await viewModel.loadPayments() } }
                        .foregroundColor(.appPrimary)
                }
            } else if viewModel.payments.isEmpty {
                Text("No payments yet.")
                    .font(.subheadline)
                    .foregroundColor(.appMutedForeground)
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.smallPadding) {
                        ForEach(viewModel.payments) { payment in
                            TransactionRowView(payment: payment)
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
        }
        .task { await viewModel.loadPayments() }
    }
}
