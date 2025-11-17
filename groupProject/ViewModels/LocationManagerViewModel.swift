// LocationManagerViewModel.swift
// groupProject
// Created by Clare Morriss

import SwiftUI
import CoreLocation

// Prologue: this view model wraps Core Location to provide current user coordinates/reactive updates
// AI and Swift documentation helped with the setup of this view model and our use & understanding of how to properly use and implement CoreLocation within our app

@MainActor
class LocationManagerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    private let manager = CLLocationManager()
    
    // initializer which configures the location manager and sets self as its delegate
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // this uses the most precise location readings
    }
    
    // requests location permission from the user & then triggers a single location update
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation() // calls delegate, which is itself, when location is received
    }
    
    // called by CLLocationManager whenever new locations are available; captures the latest result
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.userLocation = location.coordinate     // publishes the most recent location to stops unecessary searching
            manager.stopUpdatingLocation()
        }
    }
    
    // called if Core Location fails to retrieve a location (if the user denied permission, or there is some other error)
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
