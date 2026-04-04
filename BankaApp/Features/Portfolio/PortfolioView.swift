import SwiftUI

struct PortfolioView: View {
    @StateObject private var viewModel = PortfolioViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: AppTheme.padding) {
                    Text(error).font(.caption).foregroundColor(.appDestructive)
                    Button("Retry") { Task { await viewModel.load() } }
                        .foregroundColor(.appPrimary)
                }
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.padding) {
                        if let summary = viewModel.summary {
                            PortfolioSummaryCard(summary: summary)
                        }

                        if viewModel.holdings.isEmpty {
                            Text("No holdings yet.")
                                .font(.subheadline)
                                .foregroundColor(.appMutedForeground)
                                .padding()
                        } else {
                            ForEach(viewModel.holdings) { holding in
                                HoldingRowView(holding: holding)
                            }
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
        }
        .navigationTitle("Portfolio")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
    }
}

struct PortfolioSummaryCard: View {
    let summary: PortfolioSummary

    var body: some View {
        VStack(spacing: AppTheme.smallPadding) {
            if let value = summary.totalValue {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appForeground)
                Text("Total Value")
                    .font(.caption)
                    .foregroundColor(.appMutedForeground)
            }
            HStack(spacing: AppTheme.largePadding) {
                if let pl = summary.totalProfitLoss {
                    VStack {
                        Text(pl)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(pl.hasPrefix("-") ? .appDestructive : .green)
                        Text("P/L")
                            .font(.caption2)
                            .foregroundColor(.appMutedForeground)
                    }
                }
                if let count = summary.holdingsCount {
                    VStack {
                        Text("\(count)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appForeground)
                        Text("Holdings")
                            .font(.caption2)
                            .foregroundColor(.appMutedForeground)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.padding)
        .background(Color.appCard)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct HoldingRowView: View {
    let holding: Holding

    var body: some View {
        HStack(spacing: AppTheme.padding) {
            VStack(alignment: .leading, spacing: 4) {
                Text(holding.ticker)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.appForeground)
                Text(holding.name)
                    .font(.caption)
                    .foregroundColor(.appMutedForeground)
                    .lineLimit(1)
                Text(holding.securityType.capitalized)
                    .font(.caption2)
                    .foregroundColor(.appPrimary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(holding.currentPrice)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appForeground)
                Text("\(holding.quantity) shares")
                    .font(.caption)
                    .foregroundColor(.appMutedForeground)
                Text(holding.profit)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(holding.profit.hasPrefix("-") ? .appDestructive : .green)
            }
        }
        .padding(AppTheme.padding)
        .background(Color.appCard)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.appForeground.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
