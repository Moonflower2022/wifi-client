import Foundation
import CoreWLAN

class AutoJoinEngine {
    private let state: WiFiState

    init(state: WiFiState) {
        self.state = state
    }

    func pickBestNetwork() -> CWNetwork? {
        guard state.prefs.autoJoinEnabled else { return nil }

        let candidates = state.networks.filter {
            state.prefs.shouldAutoConnect(to: $0.ssid!)
        }

        return candidates.max { a, b in
            let aPri = state.prefs.priority(for: a.ssid!)
            let bPri = state.prefs.priority(for: b.ssid!)

            if aPri != bPri {
                return aPri.rawValue < bPri.rawValue
            }

            let aOrder = orderIndex(a.ssid!, priority: aPri)
            let bOrder = orderIndex(b.ssid!, priority: bPri)
            if aOrder != bOrder {
                return aOrder > bOrder
            }

            return a.rssiValue < b.rssiValue
        }
    }

    private func orderIndex(_ ssid: String, priority: Priority) -> Int {
        let ordered = state.prefs.orderedNetworks(for: priority, in: [ssid])
        return ordered.firstIndex(of: ssid) ?? 999
    }

    func autoJoinIfNeeded() {
        guard let best = pickBestNetwork() else {
            if state.currentNetwork == nil {
                print("No auto-connect networks available")
            }
            return
        }

        if let current = state.currentNetwork {
            let currentPri = state.prefs.priority(for: current)
            let bestPri = state.prefs.priority(for: best.ssid!)

            if bestPri.rawValue > currentPri.rawValue {
                print("Switching to higher priority: \(best.ssid!) (\(bestPri.label))")
                state.connect(to: best)
            }
        } else {
            print("Auto-connecting to \(best.ssid!) (\(best.rssiValue) dBm)")
            state.connect(to: best)
        }
    }
}
