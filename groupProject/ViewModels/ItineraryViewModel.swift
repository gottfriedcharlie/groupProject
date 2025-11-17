//
//  ItineraryViewModel.swift
//  groupProject
//  Created by Charlie Gottfried


import Foundation
import Combine
import MapKit


@MainActor

enum PlaceCategory: String, Codable, CaseIterable {
    case restaurant
    case hotel
    case attraction
    case museum
    case park
    case other

    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .hotel: return "bed.double"
        case .attraction: return "star"
        case .museum: return "building.columns"
        case .park: return "tree"
        case .other: return "mappin"
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

final class ItineraryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var itineraryPlaces: [ItineraryPlace] = []
    @Published var selectedTrip: Trip?                    // Track which trip we're building itinerary for
    @Published var currentOrderedPlaces: [ItineraryPlace] = []  // Places in order of visit - this is the main list
    
    private let key = "itinerary_places"
    private let tripKey = "selected_trip_key"
    
    init() {
        loadItinerary()
    }
    
    // MARK: - Itinerary Management
    
    func addPlace(_ place: GooglePlacesResult) {
        let itineraryPlace = ItineraryPlace(from: place)
        //check for duplicates before adding
        if !itineraryPlaces.contains(where: { $0.id == itineraryPlace.id }) {
            itineraryPlaces.append(itineraryPlace)
            currentOrderedPlaces.append(itineraryPlace)
            saveItinerary()
        }
    }
    
    func removePlace(_ place: ItineraryPlace) {
        itineraryPlaces.removeAll { $0.id == place.id }
        currentOrderedPlaces.removeAll { $0.id == place.id }
        saveItinerary()
    }
    
    // clear everything when done building itinerary
    func clearItinerary() {
        itineraryPlaces.removeAll()
        currentOrderedPlaces.removeAll()
        selectedTrip = nil
        saveItinerary()
    }
    
    // MARK: - NEW: Reorder places in itinerary
    // Move places around in the ordered list - important for planning the route
    func movePlaces(from source: IndexSet, to destination: Int) {
        currentOrderedPlaces.move(fromOffsets: source, toOffset: destination)
        saveItinerary()
    }
    
    // MARK: - Trip Association
    
    // Set the trip this itinerary is being built for
    func setSelectedTrip(_ trip: Trip) {
        self.selectedTrip = trip
        // Initialize search from trip's destination
        saveItinerary()
    }
    
    // Get the starting location for searches (trip destination or first place)
    // ai helped with this logic for finding the right search center
    func getSearchStartingLocation() -> CLLocationCoordinate2D? {
        // If trip has a destination coordinate, use that
        if let trip = selectedTrip, let coord = trip.destinationCoordinate {
            return coord
        }
        // Otherwise use first place in itinerary
        if let firstPlace = currentOrderedPlaces.first {
            return CLLocationCoordinate2D(latitude: firstPlace.latitude, longitude: firstPlace.longitude)
        }
        return nil
    }
    
    // Get the location for the next search (based on last added place)
    // this enables location-aware search - searches near last added place
    func getNextSearchLocation() -> CLLocationCoordinate2D? {
        // Search from the last place added to the itinerary
        if let lastPlace = currentOrderedPlaces.last {
            return CLLocationCoordinate2D(latitude: lastPlace.latitude, longitude: lastPlace.longitude)
        }
        // Fall back to trip destination
        if let trip = selectedTrip, let coord = trip.destinationCoordinate {
            return coord
        }
        return nil
    }
    
    /// Convert current ordered places to array for saving to trip
    func getItineraryForTrip() -> [ItineraryPlace] {
        return currentOrderedPlaces
    }
    
    // MARK: - Persistence
    
    private func saveItinerary() {
        if let data = try? JSONEncoder().encode(currentOrderedPlaces) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func loadItinerary() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let places = try? JSONDecoder().decode([ItineraryPlace].self, from: data) else { return }
        self.currentOrderedPlaces = places
        self.itineraryPlaces = places
    }
}

// represents a place in an itinerary with all needed info
struct ItineraryPlace: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: PlaceCategory
    let phoneNumber: String?
    let rating: Double?
    let userRatingsTotal: Int?
    
    //convert from google result to itinerary place
    init(from result: GooglePlacesResult) {
        self.id = result.id
        self.name = result.name
        self.address = result.address
        self.latitude = result.latitude
        self.longitude = result.longitude
        self.category = ItineraryPlace.mapGoogleCategory(result.placeTypes) // map google types to our categories
        self.phoneNumber = result.phoneNumber
        self.rating = result.rating
        self.userRatingsTotal = result.userRatingsTotal
    }

    // Helper function to categorize places from google types
    static func mapGoogleCategory(_ types: [String]) -> PlaceCategory {
        for type in types {
            switch type.lowercased() {
                case "restaurant": return .restaurant
                case "hotel": return .hotel
                case "attraction": return .attraction
                case "museum": return .museum
                case "park": return .park
                default: continue
            }
        }
        return .other
    }

    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

}
