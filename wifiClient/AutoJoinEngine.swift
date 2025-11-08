import Foundation
import CoreWLAN

class AutoJoinEngine {
    private let state: WiFiState
    var isEnabled = true

    init(state: WiFiState) {
        self.state = state
    }

    func pickBestNetwork() -> CWNetwork? {
        guard isEnabled else { return nil }

        let candidates = state.networks.filter {
            state.prefs.shouldAutoConnect(to: $0.ssid!)
        }

        return candidates.max { a, b in
            (a.rssiValue) < (b.rssiValue)
        }
    }

    func autoJoinIfNeeded() {
        guard state.currentNetwork == nil else {
            print("Already connected to \(state.currentNetwork ?? "unknown")")
            return
        }

        guard let best = pickBestNetwork() else {
            print("No auto-connect networks available")
            return
        }

        print("Auto-connecting to \(best.ssid!) (\(best.rssiValue) dBm)")
        state.connect(to: best)
    }
}
