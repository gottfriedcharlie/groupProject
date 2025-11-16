import Foundation

// Global view model for managing user's saved places (favorites, collections, etc.).
final class PlacesViewModel: ObservableObject {
    @Published var savedPlaces: [ItineraryPlace] = []

    // MARK: - Add a new place (if not a duplicate)
    func addPlace(_ place: ItineraryPlace) {
        guard !savedPlaces.contains(where: { $0.id == place.id }) else { return }
        savedPlaces.append(place)
        savePlaces()
    }

    // MARK: - Remove a place
    func removePlace(_ place: ItineraryPlace) {
        savedPlaces.removeAll { $0.id == place.id }
        savePlaces()
    }

    // MARK: - Update an existing place
    func updatePlace(_ place: ItineraryPlace) {
        guard let idx = savedPlaces.firstIndex(where: { $0.id == place.id }) else { return }
        savedPlaces[idx] = place
        savePlaces()
    }

    // MARK: - Persistence (UserDefaults)
    private let key = "saved_places_key"

    func savePlaces() {
        if let data = try? JSONEncoder().encode(savedPlaces) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadPlaces() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let places = try? JSONDecoder().decode([ItineraryPlace].self, from: data) else { return }
        self.savedPlaces = places
    }

    // MARK: - Initializer
    init() {
        loadPlaces()
    }
}
