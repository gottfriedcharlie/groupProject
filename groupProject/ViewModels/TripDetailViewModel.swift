import Foundation
import CoreLocation

@MainActor
final class TripDetailViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var totalDistance: Double = 0  // NEW: Track total distance
    private let parentViewModel: TripListViewModel?
    
    // MARK: - Init
    init(trip: Trip, parentViewModel: TripListViewModel? = nil) {
        self.trip = trip
        self.parentViewModel = parentViewModel
        calculateTotalDistance()
    }
    
    // MARK: - Accessors
    var places: [ItineraryPlace] {
        trip.itinerary
    }
    
    func places(for category: PlaceCategory) -> [ItineraryPlace] {
        places.filter { $0.placeTypes.contains(category.rawValue) }
    }
    
    // MARK: - NEW: Calculate distance between two locations
    func distanceBetween(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let loc2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        return loc1.distance(from: loc2) / 1000  // Convert meters to km
    }
    
    // MARK: - NEW: Calculate total distance for entire itinerary
    func calculateTotalDistance() {
        var total: Double = 0
        
        // Start from trip destination if it exists
        if let tripCoord = trip.destinationCoordinate, !trip.itinerary.isEmpty {
            let firstPlace = CLLocationCoordinate2D(
                latitude: trip.itinerary[0].latitude,
                longitude: trip.itinerary[0].longitude
            )
            total += distanceBetween(location1: tripCoord, location2: firstPlace)
        }
        
        // Calculate distance between consecutive places
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
    
    // MARK: - NEW: Get distance to next place from current
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
    
    // MARK: - Mutators (Edit, Move, Delete)
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
