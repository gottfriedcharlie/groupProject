//
//  ContentView.swift
//  groupProject
//

import SwiftUI

struct ContentView: View {
    // Get the shared view models from environment
    @EnvironmentObject var tripListViewModel: TripListViewModel
    @EnvironmentObject var itineraryViewModel: ItineraryViewModel
    
    var body: some View {
        TabView {
            TripListView()
                .tabItem {
                    Label("Trips", systemImage: "airplane")
                }
            
            ItineraryView()
                .tabItem {
                    Label("Itinerary", systemImage: "checklist")
                }
            
            NavigationView {
                MapScreen()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TripListViewModel())
        .environmentObject(ItineraryViewModel())
}
