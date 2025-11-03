//
//  ContentView.swift
//  groupProject
//
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TripListView()
                .tabItem {
                    Label("Trips", systemImage: "airplane")
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
}
