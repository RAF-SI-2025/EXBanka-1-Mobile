import Foundation
import CryptoKit

enum RequestSigner {

    struct SignatureHeaders {
        let deviceId: String
        let timestamp: String
        let signature: String
    }

    static func sign(
        method: String,
        path: String,
        body: Data?,
        deviceId: String,
        deviceSecret: String
    ) -> SignatureHeaders {
        let timestamp = String(Int(Date().timeIntervalSince1970))

        let bodyBytes = body ?? Data()
        let bodyHash = SHA256.hash(data: bodyBytes)
            .map { String(format: "%02x", $0) }
            .joined()

        let payload = "\(timestamp):\(method):\(path):\(bodyHash)"

        let secretData = Data(hexString: deviceSecret)
        let key = SymmetricKey(data: secretData)
        let hmac = HMAC<SHA256>.authenticationCode(
            for: Data(payload.utf8),
            using: key
        )
        let signature = hmac.map { String(format: "%02x", $0) }.joined()

        return SignatureHeaders(
            deviceId: deviceId,
            timestamp: timestamp,
            signature: signature
        )
    }
}

extension Data {
    init(hexString: String) {
        self.init()
        var hex = hexString
        while hex.count >= 2 {
            let byteString = String(hex.prefix(2))
            hex = String(hex.dropFirst(2))
            if let byte = UInt8(byteString, radix: 16) {
                append(byte)
            }
        }
    }
}
