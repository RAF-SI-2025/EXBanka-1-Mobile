import SwiftUI

struct LoanDetailView: View {
    let loan: Loan
    @StateObject private var viewModel: LoanDetailViewModel

    init(loan: Loan) {
        self.loan = loan
        _viewModel = StateObject(wrappedValue: LoanDetailViewModel(loanId: loan.id))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.padding) {
                    VStack(alignment: .leading, spacing: AppTheme.smallPadding) {
                        LabeledRow(label: "Type", value: loan.loanTypeLabel)
                        if let num = loan.loanNumber {
                            LabeledRow(label: "Loan Number", value: num)
                        }
                        LabeledRow(label: "Amount", value: "\(String(format: "%.2f", loan.amount)) \(loan.currencyCode ?? "RSD")")
                        LabeledRow(label: "Interest Rate", value: "\(String(format: "%.2f", loan.interestRate))%")
                        if let interestType = loan.interestType {
                            LabeledRow(label: "Interest Type", value: interestType)
                        }
                        LabeledRow(label: "Period", value: "\(loan.period) months")
                        LabeledRow(label: "Monthly Installment", value: String(format: "%.2f", loan.installmentAmount))
                        if let remaining = loan.remainingDebt {
                            LabeledRow(label: "Remaining Debt", value: String(format: "%.2f", remaining))
                        }
                        if let nextAmt = loan.nextInstallmentAmount, let nextDate = loan.nextInstallmentDate {
                            LabeledRow(label: "Next Installment", value: "\(String(format: "%.2f", nextAmt)) on \(nextDate)")
                        }
                        if let contract = loan.contractDate {
                            LabeledRow(label: "Contract Date", value: contract)
                        }
                        if let maturity = loan.maturityDate {
                            LabeledRow(label: "Maturity Date", value: maturity)
                        }
                        LabeledRow(label: "Status", value: loan.status.replacingOccurrences(of: "_", with: " ").capitalized)
                    }
                    .padding(AppTheme.padding)
                    .background(Color.appCard)
                    .cornerRadius(AppTheme.cornerRadius)

                    VStack(alignment: .leading, spacing: AppTheme.smallPadding) {
                        Text("Installments")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appForeground)

                        if viewModel.isLoading {
                            ProgressView().frame(maxWidth: .infinity).padding()
                        } else if let error = viewModel.errorMessage {
                            Text(error).font(.caption).foregroundColor(.appDestructive)
                        } else if viewModel.installments.isEmpty {
                            Text("No installments.").font(.subheadline).foregroundColor(.appMutedForeground)
                        } else {
                            ForEach(viewModel.installments) { inst in
                                HStack {
                                    Text("#\(inst.installmentNumber)")
                                        .font(.caption)
                                        .foregroundColor(.appMutedForeground)
                                        .frame(width: 30, alignment: .leading)
                                    Text(inst.dueDate)
                                        .font(.caption)
                                        .foregroundColor(.appForeground)
                                    Spacer()
                                    Text(String(format: "%.2f", inst.amount))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.appForeground)
                                    Text(inst.status)
                                        .font(.caption2)
                                        .foregroundColor(installmentStatusColor(inst.status))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(installmentStatusColor(inst.status).opacity(0.1))
                                        .cornerRadius(4)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(AppTheme.padding)
                    .background(Color.appCard)
                    .cornerRadius(AppTheme.cornerRadius)
                }
                .padding(AppTheme.padding)
            }
        }
        .navigationTitle(loan.loanTypeLabel)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadInstallments() }
    }

    private func installmentStatusColor(_ status: String) -> Color {
        switch status.uppercased() {
        case "PAID": return .green
        case "UNPAID": return .orange
        case "OVERDUE": return .appDestructive
        default: return .appMutedForeground
        }
    }
}
