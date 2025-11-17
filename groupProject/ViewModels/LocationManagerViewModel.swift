import SwiftUI
import CoreLocation

// locationManagerViewModel: wraps Core Location to provide current user coordinates
@MainActor
class LocationManagerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Triggers a one-time location update, prompts for permission if needed
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // CLLocationManagerDelegate callback: delivers new coordinates, updates published property
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.userLocation = location.coordinate
            manager.stopUpdatingLocation()
        }
    }
    
    // CLLocationManagerDelegate callback: logs errors
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
