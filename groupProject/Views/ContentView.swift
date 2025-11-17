//
//  ContentView.swift
//  groupProject
//

import SwiftUI

struct ContentView: View {
    // Get the shared view models from environment
    @EnvironmentObject var tripListViewModel: TripListViewModel
    @EnvironmentObject var itineraryViewModel: ItineraryViewModel
    @EnvironmentObject var placesViewModel: PlacesViewModel
    
    var body: some View {
        TabView {
            TripListView()
                .tabItem {
                    Label("Trips", systemImage: "airplane")
                }
            PlacesView()
                .tabItem {
                    Label("Places", systemImage: "mappin.circle")
                }
        
            NavigationView {
                MapScreen()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TripListViewModel())
        .environmentObject(ItineraryViewModel())
        .environmentObject(PlacesViewModel())
}
