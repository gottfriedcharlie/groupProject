//
//  TripDetailViewModel.swift
//  groupProject
//
//  Created by Charlie Gottfried on 10/24/25.
//

import Foundation

@MainActor
final class TripDetailViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var places: [Place] = []
    
    private let dataManager = DataManager.shared
    
    init(trip: Trip) {
        self.trip = trip
        loadPlaces()
    }
    
    func loadPlaces() {
        places = dataManager.loadPlaces(for: trip.id)
    }
    
    func addPlace(_ place: Place) {
        places.append(place)
        dataManager.savePlaces(places)
    }
    
    func deletePlace(_ place: Place) {
        places.removeAll { $0.id == place.id }
        dataManager.savePlaces(places)
    }
    
    var totalPlaces: Int {
        places.count
    }
    
    func places(for category: PlaceCategory) -> [Place] {
        places.filter { $0.category == category }
    }
}
