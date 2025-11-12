import Foundation

@MainActor
final class TripDetailViewModel: ObservableObject {
    @Published var trip: Trip
    private let parentViewModel: TripListViewModel?

    // MARK: - Init
    init(trip: Trip, parentViewModel: TripListViewModel? = nil) {
        self.trip = trip
        self.parentViewModel = parentViewModel
    }

    // MARK: - Accessors
    var places: [ItineraryPlace] {
        trip.itinerary
    }

    func places(for category: PlaceCategory) -> [ItineraryPlace] {
        places.filter { $0.placeTypes.contains(category.rawValue) }
    }

    // MARK: - Mutators (Edit, Move, Delete)
    func addPlace(_ place: ItineraryPlace) {
        var updatedTrip = trip                    // Make a copy of the Trip
        updatedTrip.itinerary.append(place)       // Mutate the copy
        trip = updatedTrip                        // Replace local reference (keeps TripDetailViewModel's .trip in sync)
        saveTrip()                                // Pass up to parent view model
    }


    func deletePlace(_ place: ItineraryPlace) {
        trip.itinerary.removeAll { $0.id == place.id }
        saveTrip()
    }

    func removePlaces(at offsets: IndexSet) {
        trip.itinerary.remove(atOffsets: offsets)
        saveTrip()
    }

    func movePlaces(from source: IndexSet, to destination: Int) {
        trip.itinerary.move(fromOffsets: source, toOffset: destination)
        saveTrip()
    }

    private func saveTrip() {
        parentViewModel?.updateTrip(trip)
    }
}
