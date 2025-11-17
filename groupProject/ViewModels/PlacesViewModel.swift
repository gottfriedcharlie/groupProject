// Colin O'Connor
// PlacesViewModel.swift
// groupProject
//
// Prologue: Global view model for managing user's saved places. This acts as a way to save places that have not been added to trips yet. Users can then add said places to trips or remove them entirely whenever they want.
import Foundation

final class PlacesViewModel: ObservableObject {
    @Published var savedPlaces: [ItineraryPlace] = [] // Array of all saved places. @Published makes it so whenever this array is changed, the UI automatically updates

    // MARK: - Add a new place
    // Adds a new place that has not already been added to an array of saved locations
    func addPlace(_ place: ItineraryPlace) {
        guard !savedPlaces.contains(where: { $0.id == place.id }) else { // compare the places ID's to see if they are duplicates
            print("Place already exists: \(place.name)")
            return
        }
        savedPlaces.append(place) // Add the new place to the array
        savePlaces()
        print("Place added to saved places: \(place.name)")
    }

    // MARK: - Remove a place
    // Removes a selected place from the array
    func removePlace(_ place: ItineraryPlace) {
        savedPlaces.removeAll { $0.id == place.id } // Remove the place matches the ID selected
        savePlaces()
        print("Place removed: \(place.name)")
    }
    // MARK: - Persistence (UserDefaults)
    // This part of the code was AI generated. We were struggling to figure out how to store the data correctly and having it stay persistantly within the app so we asked AI for help
    private let key = "saved_places_key" // Storage key for storing the places in UserDefaults

    func savePlaces() {
        if let data = try? JSONEncoder().encode(savedPlaces) { // Converts the array of places into JSON data
            UserDefaults.standard.set(data, forKey: key) // Store in UserDefaults with the key
            print("Saved \(savedPlaces.count) places to storage")
        }
    }

    // Loads saved places from the persistent storage
    func loadPlaces() {
        guard let data = UserDefaults.standard.data(forKey: key), // retrieves data from UserDefaults
              let places = try? JSONDecoder().decode([ItineraryPlace].self, from: data) else { // Decods the JSON data back into the array of places.
            print("No saved places found")
            return
        }
        self.savedPlaces = places // Update the @published to trigger the UI to refresh
        print("Loaded \(places.count) places from storage")
    }

    // MARK: - Initializer
    // Initializes the view model and loads the previously saved places
    init() {
        loadPlaces()
    }
}
