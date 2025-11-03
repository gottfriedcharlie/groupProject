//
//  ProfileView.swift
//  groupProject
//
//
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = TripListViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section("Statistics") {
                    HStack {
                        Label("Total Trips", systemImage: "airplane")
                        Spacer()
                        Text("\(viewModel.trips.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Upcoming", systemImage: "calendar")
                        Spacer()
                        Text("\(viewModel.trips.filter { $0.isUpcoming }.count)")
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Label("Past Trips", systemImage: "checkmark.circle")
                        Spacer()
                        Text("\(viewModel.trips.filter { !$0.isUpcoming }.count)")
                            .foregroundColor(.green)
                    }
                }
                
                Section("App Info") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

