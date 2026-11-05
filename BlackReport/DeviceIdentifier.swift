import Foundation
import Security

/// Identificativo anonimo dell'installazione, senza registrazione.
/// Viene generato la prima volta e salvato nel Keychain: sopravvive ai riavvii
/// e, di solito, anche alla disinstallazione/reinstallazione dell'app.
/// Non è collegato a nome, email o numero di telefono.
enum DeviceIdentifier {
    private static let service = "app.anonymous-device-id"
    private static let account = "device_uuid"

    static var current: String {
        if let existing = read() { return existing }
        let new = UUID().uuidString
        save(new)
        return new
    }

    private static func read() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func save(_ value: String) {
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: Data(value.utf8),
            // Resta su questo telefono: non viene copiato su altri dispositivi dai backup
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        SecItemAdd(attributes as CFDictionary, nil)
    }
}
