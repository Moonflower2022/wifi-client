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
        print("Attempting to connect to \(network.ssid ?? "unknown")...")
        do {
            try manager.connect(to: network, password: password)
            print("Connection initiated successfully")
        } catch {
            print("Connection error: \(error.localizedDescription)")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.refresh()
        }
    }
}
