//
//  ItineraryViewModel.swift
//  groupProject
//

import Foundation
import Combine

@MainActor
final class ItineraryViewModel: ObservableObject {
    @Published var itineraryPlaces: [ItineraryPlace] = []
    
    private let key = "itinerary_places"
    
    init() {
        loadItinerary()
    }
    
    func addPlace(_ place: GooglePlacesResult) {
        let itineraryPlace = ItineraryPlace(from: place)
        if !itineraryPlaces.contains(where: { $0.id == itineraryPlace.id }) {
            itineraryPlaces.append(itineraryPlace)
            saveItinerary()
        }
    }
    
    func removePlace(_ place: ItineraryPlace) {
        itineraryPlaces.removeAll { $0.id == place.id }
        saveItinerary()
    }
    
    func clearItinerary() {
        itineraryPlaces.removeAll()
        saveItinerary()
    }
    
    private func saveItinerary() {
        if let data = try? JSONEncoder().encode(itineraryPlaces) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func loadItinerary() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let places = try? JSONDecoder().decode([ItineraryPlace].self, from: data) else {
            return
        }
        self.itineraryPlaces = places
    }
}

// MARK: - Codable Model for Storage
struct ItineraryPlace: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let placeTypes: [String]
    let phoneNumber: String?
    let rating: Double?
    let userRatingsTotal: Int?
    
    init(from result: GooglePlacesResult) {
        self.id = result.id
        self.name = result.name
        self.address = result.address
        self.latitude = result.latitude
        self.longitude = result.longitude
        self.placeTypes = result.placeTypes
        self.phoneNumber = result.phoneNumber
        self.rating = result.rating
        self.userRatingsTotal = result.userRatingsTotal
    }
    
    func toGooglePlacesResult() -> GooglePlacesResult {
        GooglePlacesResult(
            id: id,
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude,
            placeTypes: placeTypes,
            phoneNumber: phoneNumber,
            rating: rating,
            userRatingsTotal: userRatingsTotal
        )
    }
}
