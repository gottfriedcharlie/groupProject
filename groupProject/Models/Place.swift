// Colin O'Connor
// Place.swift
// groupProject
//
// Prologue: A struct that represents a location/place that can be saved and added to trips. Uses the Google places API to get information about these places and add to their properties

import Foundation
import CoreLocation

struct Place: Identifiable, Codable, Hashable {
    // Properties
    let id: String
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var category: PlaceCategory
    var phoneNumber: String?
    var rating: Double?
    var userRatingsTotal: Int?
    var notes: String?
    var tripId: String

    // Initializers
    init(
        id: String = UUID().uuidString,
        name: String,
        address: String = "",
        latitude: Double,
        longitude: Double,
        category: PlaceCategory = .other,
        phoneNumber: String? = nil,
        rating: Double? = nil,
        userRatingsTotal: Int? = nil,
        notes: String? = nil,
        tripId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.phoneNumber = phoneNumber
        self.rating = rating
        self.userRatingsTotal = userRatingsTotal
        self.notes = notes
        self.tripId = tripId ?? ""
    }

    // Converts Google Places API results into Place objects
    // Used AI to explain how to do this part
    init(from google: GooglePlacesResult) {
        self.id = google.id
        self.name = google.name
        self.address = google.address
        self.latitude = google.latitude
        self.longitude = google.longitude
        
        // Map Google place types to PlaceCategory
        let categoryString = google.placeTypes.first?.lowercased() ?? "other"
        self.category = PlaceCategory(rawValue: categoryString) ?? .other
        
        // Optionals that copy data from Google Places API
        self.phoneNumber = google.phoneNumber
        self.rating = google.rating
        self.userRatingsTotal = google.userRatingsTotal
        self.notes = nil
        self.tripId = ""
    }
    
    // Converts the latitude and longitude into a Mapkit CLLocationCoordinate2D which allows for the it to be easily displayed on the map
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
