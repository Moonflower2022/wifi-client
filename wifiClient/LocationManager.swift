import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    var isAuthorized = false
    var onAuthChange: ((Bool) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        checkAuth()
    }

    func checkAuth() {
        let status = manager.authorizationStatus
        isAuthorized = (status == .authorizedAlways)
        print("Location auth status: \(status.rawValue)")
    }

    func requestAuth() {
        print("Requesting location permission...")
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Auth changed: \(manager.authorizationStatus.rawValue)")
        checkAuth()
        onAuthChange?(isAuthorized)
    }
}
