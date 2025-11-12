import SwiftUI
import MapKit

// Main search UI for finding places using Google Places.
// Results update *as you type*—no need to press enter.
struct MapSearchView: View {
    @ObservedObject var viewModel: MapSearchViewModel
    let onAddPlace: (GooglePlacesResult, PlaceCategory) -> Void
    @State private var selectedResult: GooglePlacesResult?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar. Typing updates `viewModel.searchText` live.
                SearchBar(text: $viewModel.searchText)
                    .padding()
                
                // Search as you type – perform the query on every text change.
                    .onChange(of: viewModel.searchText) { newQuery in
                        viewModel.searchNearby(query: newQuery)
                    }
                    
                // Display error message if search fails.
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                }
                
                // Show loading indicator during search.
                if viewModel.isLoading {
                    LoadingView()
                        .frame(maxHeight: .infinity)
                }
                // Show "no results" UI if nothing found and user has typed something.
                else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    SearchStatusView(
                        icon: "magnifyingglass",
                        title: "No Results Found",
                        subtitle: "Try searching for different keywords"
                    )
                }
                // Show results in a scrollable list.
                else if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults) { result in
                        SearchResultRow(
                            result: result,
                            userLocation: viewModel.userLocation,       // <-- pass this!
                            onTap: { selectedResult = result }
                        )
                    }
                    .listStyle(.plain)
                }
                // Default prompt when no query is active.
                else {
                    SearchStatusView(
                        icon: "map",
                        title: "Search for Places",
                        subtitle: "Search for restaurants, museums, parks, and more near you"
                    )
                }
            }
            .navigationTitle("Find Places")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        // Show details and option to add the place when a result is tapped.
        .sheet(item: $selectedResult) { result in
            PlaceDetailSheet(
                place: result,
                userLocation: viewModel.userLocation,
                onAdd: {
                    let category = viewModel.categorizePlace(result)
                    onAddPlace(result, category)
                    dismiss()
                }
            )
            .presentationDetents([.large])
        }
    }
}

// Reusable component for displaying empty and search prompt states.
struct SearchStatusView: View {
    let icon: String      // SF Symbol name
    let title: String     // Main heading
    let subtitle: String  // Secondary advice
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
}

// Material search bar UI with built-in clear button.
// Type triggers live updates via binding.
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search ice cream, museums, restaurants...", text: $text)
                .textInputAutocapitalization(.none)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

import CoreLocation
import SwiftUI

// A SwiftUI row that displays summary info for a search result (place),
// including name, address, rating, (and now distance if available).
struct SearchResultRow: View {
    let result: GooglePlacesResult
    let userLocation: CLLocationCoordinate2D?   // <-- pass this from parent view!
    let onTap: () -> Void

    // Helper to calculate straight-line distance user <-> place in meters
    private var distanceAway: Double? {
        guard let userLoc = userLocation else { return nil }
        let user = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        let placeLoc = CLLocation(latitude: result.latitude, longitude: result.longitude)
        return user.distance(from: placeLoc)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(result.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        // Rating stars and count
                        if let rating = result.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                Text(String(format: "%.1f", rating))
                                    .font(.caption2)
                                if let total = result.userRatingsTotal {
                                    Text("(\(total))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        // Distance (if available)
                        if let meters = distanceAway {
                            Text(String(format: "%.1f km", meters / 1000.0))
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 8)
        }
    }
}

import SwiftUI
import CoreLocation

// Displays detailed information about a selected place (from Google Places search),
// including its name, address, rating, phone, types, coordinates, and distance from the user.
struct PlaceDetailSheet: View {
    let place: GooglePlacesResult
    let userLocation: CLLocationCoordinate2D?    // User's current location for distance calculation
    @Environment(\.dismiss) var dismiss
    let onAdd: () -> Void

    // Calculate the straight-line distance from user to place (in meters). Returns nil if unavailable.
    private var distanceAway: Double? {
        guard let userLocation = userLocation else { return nil }
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let placeLoc = CLLocation(latitude: place.latitude, longitude: place.longitude)
        return userLoc.distance(from: placeLoc)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Place name/title
                        Text(place.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        // Place address
                        Text(place.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        // Rating and number of ratings, if available
                        if let rating = place.rating {
                            HStack(spacing: 6) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                Text(String(format: "%.1f", rating))
                                    .font(.subheadline)
                                if let count = place.userRatingsTotal {
                                    Text("(\(count) ratings)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Phone number, if available
                        if let phone = place.phoneNumber {
                            HStack(spacing: 6) {
                                Image(systemName: "phone")
                                Text(phone)
                            }
                            .font(.subheadline)
                        }

                        // Place types/categories, if any
                        if !place.placeTypes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Types:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(place.placeTypes.joined(separator: ", "))
                                    .font(.caption2)
                            }
                        }

                        // Show lat/lng for completeness (optional)
                        Text(String(format: "Lat: %.5f, Lng: %.5f", place.latitude, place.longitude))
                            .font(.caption2)
                            .foregroundColor(.gray)

                        // Distance away from user, if available
                        if let meters = distanceAway {
                            Text(String(format: "Distance: %.1f km", meters/1000))
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                }

                // "Add" button at bottom
                Button(action: onAdd) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    MapSearchView(
        viewModel: MapSearchViewModel(),
        onAddPlace: { _, _ in }
    )
}
