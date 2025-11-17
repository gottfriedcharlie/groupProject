import Foundation
import Combine

// main view model for managing the list of trips and all trip-level logic
@MainActor
final class TripListViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var searchText = ""      // for live search in the UI
    @Published var filterOption: TripFilter = .all
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let dataManager = DataManager.shared        // handles persistent storage and loading of Trip data
    private var cancellables = Set<AnyCancellable>()    // holds Combine subscriptions so they aren't deallocated prematurely

    // when the view model is created, load all trips and set up a 'listener' for the search box to check if search is used
    init() {
        loadTrips()
        setupSearchObserver()
    }

    // returns the list of trips after filtering and sorting by search and filterOption
    var filteredTrips: [Trip] {
        var result = trips
        if !searchText.isEmpty {
            result = result.filter {                                                // filter for destination & description not
                $0.destination.localizedCaseInsensitiveContains(searchText) ||      // be case sensitive
                $0.description.localizedCaseInsensitiveContains(searchText)         // ex. Paris == pAriS = PARIS
            }
        }
        // apply trip status filter (upcoming, past, or all)
        switch filterOption {
        case .upcoming: result = result.filter { $0.isUpcoming }
        case .past: result = result.filter { !$0.isUpcoming }
        case .all: break
        }
        // Always sort trips by start date (newest first)
        return result.sorted { $0.startDate > $1.startDate }
    }

    // loads the trip list from persistent storage
    func loadTrips() {
        trips = dataManager.loadTrips()
    }

    // function to add a new trip and ensure the change persists
    func addTrip(_ trip: Trip) {
        trips.append(trip)
        dataManager.saveTrips(trips)
    }

    // function to delete a trip by ID & 'saves' the new, deleted version
    func deleteTrip(_ trip: Trip) {
        trips.removeAll { $0.id == trip.id }
        dataManager.saveTrips(trips)
    }

    // function to update an existing trip
    func updateTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
            dataManager.saveTrips(trips)
        }
    }

    // function which sets the full itinerary for a trip by trip ID, replacing any previous places
    func addItineraryToTrip(_ itinerary: [ItineraryPlace], for tripId: UUID) {
        if let index = trips.firstIndex(where: { $0.id == tripId }) {
            trips[index].itinerary = itinerary
            dataManager.saveTrips(trips)
        }
    }

    // function which adds a single place to a given trip's itinerary
    func addPlaceToTrip(_ place: ItineraryPlace, toTrip tripID: UUID) {
        guard let index = trips.firstIndex(where: { $0.id == tripID }) else {
            print("Trip not found")
            return
        }
        // ensures there are no duplicates in the itinerary!!
        if !trips[index].itinerary.contains(where: { $0.id == place.id }) {
            trips[index].itinerary.append(place)
            dataManager.saveTrips(trips)
        }
    }

    // sets up a Combine publisher so UI search is debounced and triggers UI updates efficiently
    private func setupSearchObserver() {
        $searchText
            .debounce(for: 0.3, scheduler: RunLoop.main) // only runs if after 0.3 seconds of typing pause
            .sink { [weak self] _ in
                self?.objectWillChange.send() // notifies observers to refresh filteredTrips, etc
            }
            .store(in: &cancellables)         // stores in the previously established cancellables var so things are not deallocated prematurely
    }

    // adds a saved place to a trip instance directly, and updates/saves only if unique
    func addPlace(_ place: ItineraryPlace, to trip: Trip) {
        guard let idx = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        if !trips[idx].itinerary.contains(where: { $0.id == place.id }) {
            trips[idx].itinerary.append(place)
            updateTrip(trips[idx])
        }
    }
}

// available filtering options for listing trips in the UI
enum TripFilter { case all, upcoming, past }
