import Foundation

enum ConnectionState {
    case idle
    case connecting(String)
    case connected(String)
    case failed(String, String)
}

class ConnectionStatus: ObservableObject {
    @Published var state: ConnectionState = .idle

    func connecting(to ssid: String) {
        state = .connecting(ssid)
    }

    func connected(to ssid: String) {
        state = .connected(ssid)
    }

    func failed(_ ssid: String, reason: String) {
        state = .failed(ssid, reason)
    }

    func reset() {
        state = .idle
    }

    var statusMessage: String? {
        switch state {
        case .idle:
            return nil
        case .connecting(let ssid):
            return "Connecting to \(ssid)..."
        case .connected(let ssid):
            return "Connected to \(ssid)"
        case .failed(let ssid, let reason):
            return "\(ssid): \(reason)"
        }
    }

    var advice: String? {
        switch state {
        case .failed(_, let reason):
            if reason.contains("password") || reason.contains("authentication") {
                return "Check password in System Settings"
            } else if reason.contains("signal") {
                return "Move closer to router"
            } else if reason.contains("timeout") {
                return "Network may be full, try again later"
            }
            return "Check network settings"
        default:
            return nil
        }
    }
}
