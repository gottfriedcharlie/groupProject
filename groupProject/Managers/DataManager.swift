//
//  DataManager.swift
//  groupProject
//
//   
//

import Foundation

final class DataManager {
    static let shared = DataManager()
    
    private let tripsKey = "saved_trips"
    private let placesKey = "saved_places"
    
    private init() {}
    
    // MARK: - Trip Operations
    
    func loadTrips() -> [Trip] {
        guard let data = UserDefaults.standard.data(forKey: tripsKey),
              let trips = try? JSONDecoder().decode([Trip].self, from: data) else {
            return []
        }
        return trips
    }
    
    func saveTrips(_ trips: [Trip]) {
        if let data = try? JSONEncoder().encode(trips) {
            UserDefaults.standard.set(data, forKey: tripsKey)
        }
    }
    
    // MARK: - Place Operations
    
    func loadPlaces(for tripId: UUID) -> [Place] {
        let allPlaces = loadAllPlaces()
        return allPlaces.filter { $0.tripId == tripId.uuidString}
    }
    
    func loadAllPlaces() -> [Place] {
        guard let data = UserDefaults.standard.data(forKey: placesKey),
              let places = try? JSONDecoder().decode([Place].self, from: data) else {
            return []
        }
        return places
    }
    
    func savePlaces(_ places: [Place]) {
        var allPlaces = loadAllPlaces()
        
        // Remove old places for this trip
        if let firstPlace = places.first {
            allPlaces.removeAll { $0.tripId == firstPlace.tripId }
        }
        
        // Add new places
        allPlaces.append(contentsOf: places)
        
        if let data = try? JSONEncoder().encode(allPlaces) {
            UserDefaults.standard.set(data, forKey: placesKey)
        }
    }
}
