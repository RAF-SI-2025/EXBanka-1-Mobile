import Foundation
import Combine

@MainActor
final class WebSocketManager: ObservableObject {
    static let shared = WebSocketManager()

    @Published var latestChallenge: PendingVerificationItem?
    @Published var isConnected: Bool = false

    private var webSocketTask: URLSessionWebSocketTask?
    private var reconnectAttempts = 0
    private let maxBackoff: TimeInterval = 30
    private var isIntentionalDisconnect = false

    private init() {}

    func connect(accessToken: String, deviceId: String) {
        isIntentionalDisconnect = false

        guard var components = URLComponents(string: Endpoint.mobileWebSocket.urlString) else {
            return
        }
        components.queryItems = [
            URLQueryItem(name: "token", value: accessToken),
            URLQueryItem(name: "device_id", value: deviceId)
        ]
        guard let url = components.url else { return }

        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        isConnected = true
        reconnectAttempts = 0
        receiveMessage()
        schedulePing()
    }

    func disconnect() {
        isIntentionalDisconnect = true
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .success(let message):
                    self.handleMessage(message)
                    self.receiveMessage()
                case .failure:
                    self.handleDisconnect()
                }
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        let data: Data
        switch message {
        case .string(let text):
            data = Data(text.utf8)
        case .data(let d):
            data = d
        @unknown default:
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let wsMessage = try? decoder.decode(WebSocketVerificationMessage.self, from: data),
              wsMessage.type == "verification_challenge" else {
            return
        }

        latestChallenge = wsMessage.toPendingItem()
    }

    private func handleDisconnect() {
        isConnected = false
        webSocketTask = nil

        guard !isIntentionalDisconnect else { return }

        let delay = min(pow(2.0, Double(reconnectAttempts)), maxBackoff)
        reconnectAttempts += 1

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !self.isIntentionalDisconnect else { return }

            if let token = AppState.shared.accessToken,
               let deviceId = AppState.shared.deviceId {
                self.connect(accessToken: token, deviceId: deviceId)
            }
        }
    }

    private func schedulePing() {
        Task {
            try? await Task.sleep(nanoseconds: 25_000_000_000) // 25 seconds
            guard self.isConnected else { return }
            self.webSocketTask?.sendPing { [weak self] error in
                Task { @MainActor in
                    if error != nil {
                        self?.handleDisconnect()
                    } else {
                        self?.schedulePing()
                    }
                }
            }
        }
    }
}
