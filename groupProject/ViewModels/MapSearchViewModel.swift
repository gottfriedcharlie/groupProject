//
//  MapSearchViewModel.swift
//  groupProject
//

import Foundation
import MapKit
import Combine

// MARK: - Models for API Response
struct GooglePlacesResult: Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let placeTypes: [String]
    let phoneNumber: String?
    let rating: Double?
    let userRatingsTotal: Int?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Main ViewModel (with LocationDelegate at class level)
@MainActor
final class MapSearchViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties (trigger UI updates)
    @Published var searchText = ""                      // Live search string
    @Published var searchResults: [GooglePlacesResult] = [] // Results to display
    @Published var isLoading = false                    // Show/hide spinner indicator
    @Published var errorMessage: String?                // Errors sent to UI
    @Published var userLocation: CLLocationCoordinate2D?
    
    private var locationManager: CLLocationManager
    private let dataManager = DataManager.shared
    private let apiKey = "AIzaSyAI4XzQoWrI6enQ6qVFRFqP5rDckKuX9c8"
    
    // MARK: - NEW: Track the current search center (for location-aware searches)
    /// The location around which to search. Updates as user adds places to itinerary.
    @Published var currentSearchCenter: CLLocationCoordinate2D?
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Location Authorization and Updates
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - NEW: Update search center when user adds a place
    /// Call this after user adds a place to the itinerary to update search location
    func updateSearchCenter(to coordinate: CLLocationCoordinate2D) {
        self.currentSearchCenter = coordinate
        print("📍 Search center updated to: \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    // MARK: - Google Places Search
    /// Triggered when user types (called in .onChange in your view)
    func searchNearby(query: String) {
        // Use current search center, fall back to user location, then default
        let searchLocation = currentSearchCenter ?? userLocation ?? CLLocationCoordinate2D(latitude: 42.23943764672886, longitude: -71.80796616765598)
        
        guard !query.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Ensure API key is set
        if apiKey == "YOUR_GOOGLE_API_KEY_HERE" {
            errorMessage = "API key not configured. Please add your Google Places API key."
            isLoading = false
            return
        }
        
        let urlString = "https://places.googleapis.com/v1/places:searchText"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("places.name,places.displayName,places.formattedAddress,places.location,places.types,places.internationalPhoneNumber,places.rating,places.userRatingCount", forHTTPHeaderField: "X-Goog-FieldMask")
        
        let body: [String: Any] = [
            "textQuery": query,
            "locationBias": [
                "circle": [
                    "center": [
                        "latitude": searchLocation.latitude,
                        "longitude": searchLocation.longitude
                    ],
                    "radius": 5000.0  // Search within 5km of current location
                ]
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("🔍 Searching for: \(query) around (\(searchLocation.latitude), \(searchLocation.longitude))")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ Search error: \(error)")
                    return
                }
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(NewGooglePlacesResponse.self, from: data)
                    print("✅ Found \(response.places.count) places")
                    if !response.places.isEmpty {
                        self?.searchResults = response.places.map { place in
                            GooglePlacesResult(
                                id: place.name,
                                name: place.displayName.text,
                                address: place.formattedAddress,
                                latitude: place.location.latitude,
                                longitude: place.location.longitude,
                                placeTypes: place.types,
                                phoneNumber: place.internationalPhoneNumber,
                                rating: place.rating,
                                userRatingsTotal: place.userRatingCount
                            )
                        }
                    } else {
                        self?.errorMessage = "No places found for '\(query)'. Try a different search."
                        self?.searchResults = []
                    }
                } catch {
                    self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    print("❌ Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    // Determines place category for result heuristics in UI/app logic.
    func categorizePlace(_ result: GooglePlacesResult) -> PlaceCategory {
        let types = result.placeTypes.map { $0.lowercased() }
        let name = result.name.lowercased()
        if types.contains("restaurant") || name.contains("restaurant") || name.contains("cafe") {
            return .restaurant
        } else if types.contains("lodging") || types.contains("hotel") {
            return .hotel
        } else if types.contains("museum") || name.contains("museum") {
            return .museum
        } else if types.contains("park") || name.contains("park") {
            return .park
        } else if types.contains("tourist_attraction") || types.contains("landmark") {
            return .attraction
        }
        return .other
    }
}

// MARK: - Google Places API Response Models
struct NewGooglePlacesResponse: Codable {
    let places: [NewPlace]
}

struct NewPlace: Codable {
    let name: String
    let displayName: DisplayName
    let formattedAddress: String
    let location: LatLng
    let types: [String]
    let internationalPhoneNumber: String?
    let rating: Double?
    let userRatingCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case displayName
        case formattedAddress
        case location
        case types
        case internationalPhoneNumber
        case rating
        case userRatingCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.displayName = try container.decode(DisplayName.self, forKey: .displayName)
        self.formattedAddress = try container.decode(String.self, forKey: .formattedAddress)
        self.location = try container.decode(LatLng.self, forKey: .location)
        self.types = try container.decodeIfPresent([String].self, forKey: .types) ?? []
        self.internationalPhoneNumber = try container.decodeIfPresent(String.self, forKey: .internationalPhoneNumber)
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        self.userRatingCount = try container.decodeIfPresent(Int.self, forKey: .userRatingCount)
    }
}

struct DisplayName: Codable {
    let text: String
}

struct LatLng: Codable {
    let latitude: Double
    let longitude: Double
}

// MARK: - CLLocationManagerDelegate Implementation
@MainActor
extension MapSearchViewModel: CLLocationManagerDelegate {
    // Updates userLocation when a new location is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location.coordinate
        
        // Initialize search center to user location if not already set
        if currentSearchCenter == nil {
            currentSearchCenter = location.coordinate
        }
        
        print("📍 User location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    // Handles location failures and updates error message.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location error: \(error.localizedDescription)"
        print("❌ Location error: \(error)")
    }
}
