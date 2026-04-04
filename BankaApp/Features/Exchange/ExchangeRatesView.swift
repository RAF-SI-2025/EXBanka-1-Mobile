import SwiftUI

struct ExchangeRatesView: View {
    @StateObject private var viewModel = ExchangeRatesViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: AppTheme.padding) {
                    Text(error).font(.caption).foregroundColor(.appDestructive)
                    Button("Retry") { Task { await viewModel.loadRates() } }
                        .foregroundColor(.appPrimary)
                }
            } else if viewModel.rates.isEmpty {
                Text("No rates available.")
                    .font(.subheadline)
                    .foregroundColor(.appMutedForeground)
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.smallPadding) {
                        ForEach(viewModel.rates) { rate in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(rate.fromCurrency) → \(rate.toCurrency)")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.appForeground)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    HStack(spacing: AppTheme.smallPadding) {
                                        VStack(alignment: .trailing) {
                                            Text("Buy")
                                                .font(.caption2)
                                                .foregroundColor(.appMutedForeground)
                                            Text(rate.buyRate)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.green)
                                        }
                                        VStack(alignment: .trailing) {
                                            Text("Sell")
                                                .font(.caption2)
                                                .foregroundColor(.appMutedForeground)
                                            Text(rate.sellRate)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.appDestructive)
                                        }
                                    }
                                }
                            }
                            .padding(AppTheme.padding)
                            .background(Color.appCard)
                            .cornerRadius(AppTheme.cornerRadius)
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
        }
        .navigationTitle("Exchange Rates")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.loadRates() }
    }
}
