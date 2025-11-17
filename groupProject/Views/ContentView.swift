//
//  ContentView.swift
//Charlie Gottfried
//  groupProject
//The app's home base. Three tabs at the bottom: My Trips, saved Places, and the Map. Switch between them to navigate the whole app.

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
