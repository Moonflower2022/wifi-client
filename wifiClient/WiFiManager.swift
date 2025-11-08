import Foundation
import CoreWLAN

class WiFiManager {
    private let client = CWWiFiClient.shared()
    private var interface: CWInterface? { client.interface() }

    func scanNetworks() -> [CWNetwork] {
        guard let interface = interface else {
            print("No WiFi interface available")
            return []
        }

        print("WiFi powered: \(interface.powerOn())")
        print("Interface name: \(interface.interfaceName ?? "unknown")")

        do {
            print("Scanning for networks...")
            let networks = try interface.scanForNetworks(withSSID: nil)
            print("Found \(networks.count) networks")

            let filtered = networks.filter { $0.ssid != nil && !$0.ssid!.isEmpty }
            print("After filtering nil SSIDs: \(filtered.count) networks")

            let unique = Dictionary(grouping: filtered, by: { $0.ssid! })
                .values.compactMap { $0.max(by: { $0.rssiValue < $1.rssiValue }) }
            print("Unique networks: \(unique.count)")

            for net in unique.prefix(3) {
                print("  - \(net.ssid!) @ \(net.rssiValue) dBm")
            }

            return unique.sorted { $0.ssid! < $1.ssid! }
        } catch {
            print("Scan error: \(error)")
            return []
        }
    }

    func currentNetwork() -> String? {
        interface?.ssid()
    }

    func connect(to network: CWNetwork, password: String?) throws {
        guard let interface = interface else {
            throw NSError(domain: "WiFi", code: -1, userInfo: [NSLocalizedDescriptionKey: "No WiFi interface"])
        }
        try interface.associate(to: network, password: password)
    }

    var isOn: Bool {
        interface?.powerOn() ?? false
    }
}
