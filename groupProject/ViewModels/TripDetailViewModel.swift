import Foundation
import CoreLocation

// View model for TripDetailView, handles business logic and live updates for a trip's data.
@MainActor
final class TripDetailViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var totalDistance: Double = 0      // In miles
    private let parentViewModel: TripListViewModel?

    init(trip: Trip, parentViewModel: TripListViewModel? = nil) {
        self.trip = trip
        self.parentViewModel = parentViewModel
        calculateTotalDistance()
    }

    var places: [ItineraryPlace] { trip.itinerary }

    func distanceBetween(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let loc2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        return loc1.distance(from: loc2) / 1609.344 // Miles
    }

    func calculateTotalDistance() {
        var total: Double = 0
        if let tripCoord = trip.destinationCoordinate, !trip.itinerary.isEmpty {
            let firstPlace = CLLocationCoordinate2D(
                latitude: trip.itinerary[0].latitude,
                longitude: trip.itinerary[0].longitude
            )
            total += distanceBetween(location1: tripCoord, location2: firstPlace)
        }
        if trip.itinerary.count > 1 {
            for i in 0..<(trip.itinerary.count - 1) {
                let currentPlace = CLLocationCoordinate2D(
                    latitude: trip.itinerary[i].latitude,
                    longitude: trip.itinerary[i].longitude
                )
                let nextPlace = CLLocationCoordinate2D(
                    latitude: trip.itinerary[i + 1].latitude,
                    longitude: trip.itinerary[i + 1].longitude
                )
                total += distanceBetween(location1: currentPlace, location2: nextPlace)
            }
        }
        self.totalDistance = total
    }

    func distanceToNext(from index: Int) -> Double? {
        guard index < trip.itinerary.count - 1 else { return nil }
        let currentPlace = CLLocationCoordinate2D(
            latitude: trip.itinerary[index].latitude,
            longitude: trip.itinerary[index].longitude
        )
        let nextPlace = CLLocationCoordinate2D(
            latitude: trip.itinerary[index + 1].latitude,
            longitude: trip.itinerary[index + 1].longitude
        )
        return distanceBetween(location1: currentPlace, location2: nextPlace)
    }
    
    var totalDistanceString: String {
        // Adapts your totalDistance (in miles) to a nicely formatted string for display
        String(format: "%.1f miles", totalDistance)
    }

    // MARK: - Mutators
    func addPlace(_ place: ItineraryPlace) {
        var updatedTrip = trip
        updatedTrip.itinerary.append(place)
        trip = updatedTrip
        calculateTotalDistance()
        saveTrip()
    }
    func deletePlace(_ place: ItineraryPlace) {
        trip.itinerary.removeAll { $0.id == place.id }
        calculateTotalDistance()
        saveTrip()
    }
    func removePlaces(at offsets: IndexSet) {
        trip.itinerary.remove(atOffsets: offsets)
        calculateTotalDistance()
        saveTrip()
    }
    func movePlaces(from source: IndexSet, to destination: Int) {
        trip.itinerary.move(fromOffsets: source, toOffset: destination)
        calculateTotalDistance()
        saveTrip()
    }
    private func saveTrip() {
        parentViewModel?.updateTrip(trip)
    }
}
