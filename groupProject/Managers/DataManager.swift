//
//  DataManager.swift
//  groupProject
//
// Handles saving and loading all the app's data to the device. Stores trips and places locally using UserDefaults so everything persists even after closing the app.

import Foundation

final class DataManager {
    static let shared = DataManager()
    
    private let tripsKey = "saved_trips"
    private let placesKey = "saved_places"
    
    private init() {}
    
    // MARK: - Trip Operations
    
    //loads all trips from storage
    func loadTrips() -> [Trip] {
        guard let data = UserDefaults.standard.data(forKey: tripsKey),
              let trips = try? JSONDecoder().decode([Trip].self, from: data) else {
            return []
        }
        return trips
    }
    
    //save trips to storage
    func saveTrips(_ trips: [Trip]) {
        if let data = try? JSONEncoder().encode(trips) {
            UserDefaults.standard.set(data, forKey: tripsKey)
        }
    }
    
    // MARK: - Place Operations
    
    //load places for spedfics trips
    func loadPlaces(for tripId: UUID) -> [Place] {
        let allPlaces = loadAllPlaces()
        return allPlaces.filter { $0.tripId == tripId.uuidString}
    }
    
    //load all places from storage
    func loadAllPlaces() -> [Place] {
        guard let data = UserDefaults.standard.data(forKey: placesKey),
              let places = try? JSONDecoder().decode([Place].self, from: data) else {
            return []
        }
        return places
    }
    
    //save places to storage
    func savePlaces(_ places: [Place]) {
        var allPlaces = loadAllPlaces()
        
        //remove old places for this trip
        if let firstPlace = places.first {
            allPlaces.removeAll { $0.tripId == firstPlace.tripId }
        }
        
        //add new place
        allPlaces.append(contentsOf: places)
        
        if let data = try? JSONEncoder().encode(allPlaces) {
            UserDefaults.standard.set(data, forKey: placesKey)
        }
    }
}
