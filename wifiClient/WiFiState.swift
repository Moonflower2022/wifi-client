import Foundation
import CoreWLAN
import Observation

@Observable
class WiFiState {
    var networks: [CWNetwork] = []
    var currentNetwork: String?
    var prefs = NetworkPrefs.load()
    var isScanning = false
    var hasLocationPermission = false
    var connectionStatus = ConnectionStatus()

    private let manager = WiFiManager()
    private var scanTimer: Timer?
    private let locationMgr = LocationManager.shared

    init() {
        locationMgr.onAuthChange = { [weak self] authorized in
            self?.hasLocationPermission = authorized
            if authorized { self?.startScanning() }
        }

        if locationMgr.isAuthorized {
            hasLocationPermission = true
            startScanning()
        } else {
            locationMgr.requestAuth()
        }
    }

    func startScanning() {
        print("Starting WiFi scanning...")
        refresh()
        scanTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func refresh() {
        isScanning = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let nets = manager.scanNetworks()
            let current = manager.currentNetwork()
            DispatchQueue.main.async {
                self.networks = nets
                self.currentNetwork = current
                self.isScanning = false
            }
        }
    }

    func connect(to network: CWNetwork, password: String? = nil) {
        let ssid = network.ssid ?? "unknown"
        connectionStatus.connecting(to: ssid)
        print("Attempting to connect to \(ssid)...")

        do {
            try manager.connect(to: network, password: password)
            print("Connection initiated successfully")
        } catch {
            let msg = parseError(error)
            connectionStatus.failed(ssid, reason: msg)
            print("Connection error: \(msg)")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.refresh()
            if self.currentNetwork == ssid {
                self.connectionStatus.connected(to: ssid)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.connectionStatus.reset()
                }
            }
        }
    }

    private func parseError(_ error: Error) -> String {
        let desc = error.localizedDescription
        if desc.contains("password") || desc.contains("authentication") {
            return "Wrong password or authentication failed"
        } else if desc.contains("timeout") {
            return "Connection timeout"
        } else if desc.contains("signal") {
            return "Weak signal strength"
        }
        return "Connection failed"
    }
}
