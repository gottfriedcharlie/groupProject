import Foundation
import CoreLocation

struct Trip: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var destination: String
    var destinationLatitude: Double?
    var destinationLongitude: Double?
    var startDate: Date
    var endDate: Date
    var description: String
    var budget: Double
    var imageURL: String?
    var itinerary: [ItineraryPlace]

    init(
        id: UUID = UUID(),
        name: String,
        destination: String,
        destinationLatitude: Double? = nil,
        destinationLongitude: Double? = nil,
        startDate: Date,
        endDate: Date,
        description: String = "",
        budget: Double = 0,
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
        self.budget = budget
        self.imageURL = imageURL
        self.itinerary = itinerary
    }

    var destinationCoordinate: CLLocationCoordinate2D? {
        guard let lat = destinationLatitude, let lon = destinationLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var durationInDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }

    var isUpcoming: Bool {
        startDate > Date()
    }

    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
