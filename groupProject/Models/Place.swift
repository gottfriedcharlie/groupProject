import Foundation
import CoreLocation

struct Place: Identifiable, Codable, Hashable {
    let id: String                   // Google Place ID, or UUID.string for custom entries
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var category: PlaceCategory
    var phoneNumber: String?
    var rating: Double?
    var userRatingsTotal: Int?
    var notes: String?               // Optional user field
    var tripId: String              // Store trip association if needed

    init(
        id: String,
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        category: String? = nil,
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
        PlaceCategory(rawValue: (self.category = category)!) ?? <#default value#>
        self.phoneNumber = phoneNumber
        self.rating = rating
        self.userRatingsTotal = userRatingsTotal
        self.notes = notes
        self.tripId = tripId
    }

    init(from google: GooglePlacesResult) {
        self.id = google.id
        self.name = google.name
        self.address = google.address
        self.latitude = google.latitude
        self.longitude = google.longitude
        PlaceCategory(rawValue: (self.category = google.placeTypes.first)!) ?? <#default value#>
        self.phoneNumber = google.phoneNumber
        self.rating = google.rating
        self.userRatingsTotal = google.userRatingsTotal
        self.notes = nil
        self.tripId = nil
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
