import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case unauthorized
    case deviceDeactivated

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError(let e): return e.localizedDescription
        case .httpError(_, let msg): return msg
        case .decodingError(let e): return "Decode error: \(e.localizedDescription)"
        case .unauthorized: return "Session expired. Please log in again."
        case .deviceDeactivated: return "Device has been deactivated. Please re-activate."
        }
    }
}

actor APIClient {
    static let shared = APIClient()
    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    private init() {}

    // MARK: - Standard request (with optional X-Device-ID)

    func request<T: Decodable>(
        endpoint: Endpoint,
        body: Encodable? = nil,
        accessToken: String? = nil,
        deviceId: String? = nil
    ) async throws -> T {
        guard let url = URL(string: endpoint.urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let deviceId {
            request.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")
        }

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        return try await execute(request: request)
    }

    // MARK: - Signed request (for verification endpoints)

    func signedRequest<T: Decodable>(
        endpoint: Endpoint,
        body: Encodable? = nil,
        accessToken: String,
        deviceId: String,
        deviceSecret: String
    ) async throws -> T {
        guard let url = URL(string: endpoint.urlString) else {
            throw APIError.invalidURL
        }

        let bodyData: Data?
        if let body {
            bodyData = try encoder.encode(body)
        } else {
            bodyData = nil
        }

        let headers = RequestSigner.sign(
            method: endpoint.method,
            path: endpoint.path,
            body: bodyData,
            deviceId: deviceId,
            deviceSecret: deviceSecret
        )

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(headers.deviceId, forHTTPHeaderField: "X-Device-ID")
        request.setValue(headers.timestamp, forHTTPHeaderField: "X-Device-Timestamp")
        request.setValue(headers.signature, forHTTPHeaderField: "X-Device-Signature")
        request.httpBody = bodyData

        return try await execute(request: request)
    }

    // MARK: - Token refresh

    func refreshTokens(
        refreshToken: String,
        deviceId: String
    ) async throws -> MobileRefreshResponse {
        guard let url = URL(string: Endpoint.mobileRefresh.urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")
        request.httpBody = try encoder.encode(MobileRefreshRequest(refreshToken: refreshToken))

        return try await execute(request: request)
    }

    // MARK: - Shared execution

    private func execute<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        if http.statusCode == 401 {
            let errorBody = try? JSONDecoder().decode(APIErrorBody.self, from: data)
            if errorBody?.error.code == "device_deactivated" {
                throw APIError.deviceDeactivated
            }
            throw APIError.unauthorized
        }

        guard (200..<300).contains(http.statusCode) else {
            let message: String
            if let structured = try? JSONDecoder().decode(APIErrorBody.self, from: data) {
                message = structured.error.message
            } else if let simple = try? JSONDecoder().decode(APIErrorSimple.self, from: data) {
                message = simple.error
            } else {
                message = "HTTP \(http.statusCode)"
            }
            throw APIError.httpError(statusCode: http.statusCode, message: message)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// Structured error: {"error": {"code": "...", "message": "..."}}
private struct APIErrorBody: Decodable {
    let error: APIErrorDetail
    struct APIErrorDetail: Decodable {
        let code: String
        let message: String
    }
}

// Simple error: {"error": "message"}
private struct APIErrorSimple: Decodable {
    let error: String
}
