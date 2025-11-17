//
//  TravelApp.swift
//  groupProject
//Sets up the app when it launches. Initializes the three main view models that handle trips, places, and the map, then passes them down so every screen can access the same data.

import SwiftUI

@main
struct TravelApp: App {
    @StateObject private var listViewModel = TripListViewModel()
    @StateObject private var itineraryViewModel = ItineraryViewModel()
    @StateObject private var placesViewModel = PlacesViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(listViewModel)
                .environmentObject(itineraryViewModel)
                .environmentObject(placesViewModel)
        }
    }
}
