//
//  TravelApp.swift
//  groupProject
//

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
