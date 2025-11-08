import Foundation

struct NetworkPrefs: Codable {
    var autoConnect: [String: Bool] = [:]

    func shouldAutoConnect(to ssid: String) -> Bool {
        autoConnect[ssid] ?? false
    }

    mutating func setAutoConnect(_ enabled: Bool, for ssid: String) {
        autoConnect[ssid] = enabled
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "network_prefs")
        }
    }

    static func load() -> NetworkPrefs {
        guard let data = UserDefaults.standard.data(forKey: "network_prefs"),
              let prefs = try? JSONDecoder().decode(NetworkPrefs.self, from: data) else {
            return NetworkPrefs()
        }
        return prefs
    }
}
