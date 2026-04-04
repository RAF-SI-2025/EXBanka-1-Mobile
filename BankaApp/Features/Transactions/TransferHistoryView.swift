import SwiftUI

struct TransferHistoryView: View {
    @StateObject private var viewModel = TransferHistoryViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: AppTheme.padding) {
                    Text(error).font(.caption).foregroundColor(.appDestructive)
                    Button("Retry") { Task { await viewModel.loadTransfers() } }
                        .foregroundColor(.appPrimary)
                }
            } else if viewModel.transfers.isEmpty {
                Text("No transfers yet.")
                    .font(.subheadline)
                    .foregroundColor(.appMutedForeground)
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.smallPadding) {
                        ForEach(viewModel.transfers) { transfer in
                            TransferRowView(transfer: transfer)
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
        }
        .task { await viewModel.loadTransfers() }
    }
}

struct TransferRowView: View {
    let transfer: Transfer

    private var formattedDate: String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let iso2 = ISO8601DateFormatter()
        if let date = iso.date(from: transfer.timestamp) ?? iso2.date(from: transfer.timestamp) {
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .short
            return f.string(from: date)
        }
        return transfer.timestamp
    }

    var body: some View {
        HStack(spacing: AppTheme.smallPadding) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appPrimary.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .foregroundColor(.appPrimary)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(transfer.fromAccountNumber)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appForeground)
                    .lineLimit(1)
                Text("→ \(transfer.toAccountNumber)")
                    .font(.caption)
                    .foregroundColor(.appMutedForeground)
                    .lineLimit(1)
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundColor(.appMutedForeground)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "%.2f", transfer.finalAmount))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appForeground)
                if let rate = transfer.exchangeRate, rate != 1.0 {
                    Text("Rate: \(String(format: "%.4f", rate))")
                        .font(.caption2)
                        .foregroundColor(.appMutedForeground)
                }
            }
        }
        .padding(AppTheme.smallPadding + 4)
        .background(Color.appCard)
        .cornerRadius(AppTheme.cornerRadius)
    }
}
