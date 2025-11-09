import Foundation

enum Priority: Int, Codable, CaseIterable {
    case high = 3
    case medium = 2
    case low = 1
    case never = 0

    var label: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        case .never: return "Never"
        }
    }
}

struct NetworkPrefs: Codable {
    var priorities: [String: Priority] = [:]
    var ordering: [String: [String]] = [:]
    var autoJoinEnabled = true

    func priority(for ssid: String) -> Priority {
        priorities[ssid] ?? .medium
    }

    func shouldAutoConnect(to ssid: String) -> Bool {
        guard autoJoinEnabled else { return false }
        return priority(for: ssid) != .never
    }

    mutating func setPriority(_ priority: Priority, for ssid: String) {
        priorities[ssid] = priority
        addToOrdering(ssid, priority: priority)
    }

    private mutating func addToOrdering(_ ssid: String, priority: Priority) {
        let key = "\(priority.rawValue)"
        var list = ordering[key] ?? []
        if !list.contains(ssid) {
            list.append(ssid)
        }
        ordering[key] = list
    }

    mutating func moveUp(_ ssid: String, in priority: Priority) {
        let key = "\(priority.rawValue)"
        var list = ordering[key] ?? []
        if let idx = list.firstIndex(of: ssid), idx > 0 {
            list.swapAt(idx, idx - 1)
            ordering[key] = list
        }
    }

    mutating func moveDown(_ ssid: String, in priority: Priority) {
        let key = "\(priority.rawValue)"
        var list = ordering[key] ?? []
        if let idx = list.firstIndex(of: ssid), idx < list.count - 1 {
            list.swapAt(idx, idx + 1)
            ordering[key] = list
        }
    }

    func orderedNetworks(for priority: Priority, in ssids: [String]) -> [String] {
        let key = "\(priority.rawValue)"
        let ordered = ordering[key] ?? []
        let filtered = ssids.filter { self.priority(for: $0) == priority }
        return ordered.filter { filtered.contains($0) } +
               filtered.filter { !ordered.contains($0) }
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
