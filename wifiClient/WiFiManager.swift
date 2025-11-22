import Foundation
import CoreWLAN

class WiFiManager {
    private let client = CWWiFiClient.shared()
    private var interface: CWInterface? { client.interface() }

    func scanNetworks() -> [CWNetwork] {
        []
    }
}
