//
//  ContentView.swift
//  groupProject
//

import SwiftUI

struct ContentView: View {
    // Get the shared view models from environment
    // these get passed down from TravelApp.swift so all views can access same data
    @EnvironmentObject var tripListViewModel: TripListViewModel
    @EnvironmentObject var itineraryViewModel: ItineraryViewModel
    @EnvironmentObject var placesViewModel: PlacesViewModel
    
    var body: some View {
        TabView {
            TripListView()
                .tabItem {
                    Label("Trips", systemImage: "airplane")
                }
            //places tab for saved locations not yet assigned to trips
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
