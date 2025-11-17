import Foundation
import CoreLocation

// data model for Trip objects
struct Trip: Identifiable, Codable, Hashable {
    let id: UUID                        // unique trip identifier, system-generated if not provided
    var name: String
    var destination: String
    var destinationLatitude: Double?    // optional latitude of the destination city/place
    var destinationLongitude: Double?   // optional longitude of the destination city/place
    var startDate: Date
    var endDate: Date
    var description: String
    var imageURL: String?
    var itinerary: [ItineraryPlace]

    // custom initializer allows setting all fields with sensible defaults
    init(
        id: UUID = UUID(),
        name: String,
        destination: String,
        destinationLatitude: Double? = nil,
        destinationLongitude: Double? = nil,
        startDate: Date,
        endDate: Date,
        description: String = "",
        imageURL: String? = nil,
        itinerary: [ItineraryPlace] = []
    ) {
        self.id = id
        self.name = name
        self.destination = destination
        self.destinationLatitude = destinationLatitude
        self.destinationLongitude = destinationLongitude
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
        self.imageURL = imageURL
        self.itinerary = itinerary
    }

    // returns user's destination as a CoreLocation object, if coordinates are available
    var destinationCoordinate: CLLocationCoordinate2D? {
        guard let lat = destinationLatitude, let lon = destinationLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    // calculates number of whole days from start to end date (for display purposes)
    var durationInDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }

    // returns true if the trip's start date is in the future, this is used for filtering trips
    var isUpcoming: Bool {
        startDate > Date()
    }

    // formats start & end dates as a readable string
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
