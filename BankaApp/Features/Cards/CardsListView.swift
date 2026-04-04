import SwiftUI

struct CardsListView: View {
    @StateObject private var viewModel = CardsListViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: AppTheme.padding) {
                    Text(error).font(.caption).foregroundColor(.appDestructive)
                    Button("Retry") { Task { await viewModel.loadCards() } }
                        .foregroundColor(.appPrimary)
                }
            } else if viewModel.cards.isEmpty {
                Text("No cards found.")
                    .font(.subheadline)
                    .foregroundColor(.appMutedForeground)
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.smallPadding) {
                        ForEach(viewModel.cards) { card in
                            NavigationLink(destination: CardDetailView(card: card)) {
                                CardRowView(card: card)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
        }
        .navigationTitle("Cards")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.loadCards() }
    }
}
