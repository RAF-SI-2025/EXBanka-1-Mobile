import SwiftUI

struct LoansListView: View {
    @StateObject private var viewModel = LoansListViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: AppTheme.padding) {
                    Text(error).font(.caption).foregroundColor(.appDestructive)
                    Button("Retry") { Task { await viewModel.loadLoans() } }
                        .foregroundColor(.appPrimary)
                }
            } else if viewModel.loans.isEmpty {
                Text("No loans found.")
                    .font(.subheadline)
                    .foregroundColor(.appMutedForeground)
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.smallPadding) {
                        ForEach(viewModel.loans) { loan in
                            NavigationLink(destination: LoanDetailView(loan: loan)) {
                                LoanRowView(loan: loan)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
        }
        .navigationTitle("Loans")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.loadLoans() }
    }
}

struct LoanRowView: View {
    let loan: Loan

    var body: some View {
        HStack(spacing: AppTheme.padding) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "building.columns.fill")
                    .foregroundColor(.appPrimary)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(loan.loanTypeLabel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appForeground)
                Text("\(String(format: "%.2f", loan.amount)) \(loan.currencyCode ?? "RSD")")
                    .font(.caption)
                    .foregroundColor(.appMutedForeground)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(String(format: "%.1f", loan.interestRate))%")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appForeground)
                Text(loan.status.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.caption2)
                    .foregroundColor(loanStatusColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(loanStatusColor.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(AppTheme.padding)
        .background(Color.appCard)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.appForeground.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var loanStatusColor: Color {
        switch loan.status.uppercased() {
        case "ACTIVE": return .green
        case "PAID_OFF": return .appPrimary
        case "DELINQUENT": return .appDestructive
        default: return .appMutedForeground
        }
    }
}
