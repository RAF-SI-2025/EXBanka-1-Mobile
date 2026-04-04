import SwiftUI

struct CardDetailView: View {
    let card: Card
    @State private var showPIN: Bool = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.padding) {
                    CardVisual(card: card)

                    VStack(alignment: .leading, spacing: AppTheme.smallPadding) {
                        LabeledRow(label: "Card Name", value: card.cardName)
                        LabeledRow(label: "Card Number", value: card.maskedNumber)
                        LabeledRow(label: "Type", value: card.cardType)
                        LabeledRow(label: "Brand", value: card.brand)
                        LabeledRow(label: "Expires", value: card.expiryFormatted)
                        LabeledRow(label: "Account", value: card.accountNumber)
                        if let owner = card.ownerName {
                            LabeledRow(label: "Owner", value: owner)
                        }
                        if let limit = card.limit {
                            LabeledRow(label: "Limit", value: String(format: "%.2f", limit))
                        }
                        LabeledRow(label: "Status", value: card.status.capitalized)

                        if let cvv = card.cvv {
                            HStack {
                                Text("CVV")
                                    .font(.caption)
                                    .foregroundColor(.appMutedForeground)
                                Spacer()
                                Text(showPIN ? cvv : "***")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.appForeground)
                                Button(action: { showPIN.toggle() }) {
                                    Image(systemName: showPIN ? "eye.slash.fill" : "eye.fill")
                                        .font(.caption)
                                        .foregroundColor(.appPrimary)
                                }
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
        .navigationTitle(card.cardName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CardVisual: View {
    let card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.padding) {
            HStack {
                Text(card.brand)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(card.cardType)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Text(card.maskedNumber)
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)

            HStack {
                VStack(alignment: .leading) {
                    Text("EXPIRES")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.6))
                    Text(card.expiryFormatted)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                Spacer()
                if let owner = card.ownerName {
                    Text(owner.uppercased())
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(AppTheme.largePadding)
        .frame(height: 200)
        .background(
            LinearGradient(
                colors: [Color.appPrimary, Color.appAccent.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppTheme.cornerRadius * 1.4)
        .shadow(color: Color.appPrimary.opacity(0.3), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius * 1.4)
                .fill(card.status.uppercased() != "ACTIVE" ? Color.black.opacity(0.4) : Color.clear)
                .overlay(
                    card.status.uppercased() != "ACTIVE" ?
                    Text(card.status.uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    : nil
                )
        )
    }
}
