//
//  TravelApp.swift
//  groupProject
//
//
//

import SwiftUI

@main
struct TravelApp: App {
    @StateObject private var listViewModel = TripListViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(listViewModel)
        }
    }
}
