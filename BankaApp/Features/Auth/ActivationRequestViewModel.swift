import Foundation

@MainActor
final class ActivationRequestViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var codeSent: Bool = false

    func requestActivation() async {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let _: ActivationRequestResponse = try await APIClient.shared.request(
                endpoint: .mobileRequestActivation,
                body: ActivationRequest(email: trimmed)
            )
            codeSent = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
