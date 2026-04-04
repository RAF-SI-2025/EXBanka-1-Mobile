import Foundation

struct Loan: Decodable, Identifiable {
    let id: Int
    let loanNumber: String?
    let loanType: String
    let accountNumber: String?
    let amount: Double
    let interestRate: Double
    let nominalInterestRate: Double?
    let effectiveInterestRate: Double?
    let interestType: String?
    let period: Int
    let installmentAmount: Double
    let contractDate: String?
    let maturityDate: String?
    let nextInstallmentAmount: Double?
    let nextInstallmentDate: String?
    let remainingDebt: Double?
    let currencyCode: String?
    let status: String
    let createdAt: String?

    var loanTypeLabel: String {
        switch loanType.uppercased() {
        case "CASH": return "Cash Loan"
        case "HOUSING": return "Housing Loan"
        case "AUTO": return "Auto Loan"
        case "REFINANCING": return "Refinancing"
        case "STUDENT": return "Student Loan"
        default: return loanType
        }
    }
}

struct LoansResponse: Decodable {
    let loans: [Loan]
    let total: Int
}

struct LoanInstallment: Decodable, Identifiable {
    var id: Int { installmentNumber }
    let installmentNumber: Int
    let dueDate: String
    let amount: Double
    let status: String
}

struct InstallmentsResponse: Decodable {
    let installments: [LoanInstallment]
}
