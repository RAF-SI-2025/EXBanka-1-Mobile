import SwiftUI

struct CardRowView: View {
    let card: Card

    var body: some View {
        HStack(spacing: AppTheme.padding) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(brandColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "creditcard.fill")
                    .foregroundColor(brandColor)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(card.cardName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appForeground)
                    .lineLimit(1)
                Text(card.maskedNumber)
                    .font(.caption)
                    .foregroundColor(.appMutedForeground)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(card.brand)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.appForeground)
                Text(card.status.capitalized)
                    .font(.caption2)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(AppTheme.padding)
        .background(Color.appCard)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.appForeground.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var brandColor: Color {
        switch card.brand.uppercased() {
        case "VISA": return .blue
        case "MASTERCARD": return .orange
        case "AMEX": return .green
        default: return .appPrimary
        }
    }

    private var statusColor: Color {
        switch card.status.uppercased() {
        case "ACTIVE": return .green
        case "BLOCKED": return .orange
        case "DEACTIVATED": return .appDestructive
        default: return .appMutedForeground
        }
    }
}
