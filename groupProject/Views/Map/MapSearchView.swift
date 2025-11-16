import SwiftUI
import MapKit
import CoreLocation

struct MapSearchView: View {
    @ObservedObject var viewModel: MapSearchViewModel
    let onAddPlace: (GooglePlacesResult, PlaceCategory) -> Void
    @State private var selectedResult: GooglePlacesResult?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText)
                    .padding()
                    .onChange(of: viewModel.searchText) { newQuery in
                        viewModel.searchNearby(query: newQuery)
                    }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                }
                if viewModel.isLoading {
                    LoadingView()
                        .frame(maxHeight: .infinity)
                } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    SearchStatusView(
                        icon: "magnifyingglass",
                        title: "No Results Found",
                        subtitle: "Try searching for different keywords"
                    )
                } else if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults) { result in
                        SearchResultRow(
                            result: result,
                            userLocation: viewModel.userLocation,
                            onTap: { selectedResult = result }
                        )
                    }
                    .listStyle(.plain)
                } else {
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

struct SearchStatusView: View {
    let icon: String
    let title: String
    let subtitle: String

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

struct SearchResultRow: View {
    let result: GooglePlacesResult
    let userLocation: CLLocationCoordinate2D?
    let onTap: () -> Void

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
                        if let userLoc = userLocation {
                            Text(formattedImperialDistance(from: userLoc, to: result.coordinate))
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

struct PlaceDetailSheet: View {
    let place: GooglePlacesResult
    let userLocation: CLLocationCoordinate2D?
    @Environment(\.dismiss) var dismiss
    let onAdd: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(place.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(place.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
                        if let phone = place.phoneNumber {
                            HStack(spacing: 6) {
                                Image(systemName: "phone")
                                Text(phone)
                            }
                            .font(.subheadline)
                        }
                        if !place.placeTypes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Types:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(place.placeTypes.joined(separator: ", "))
                                    .font(.caption2)
                            }
                        }
                        Text(String(format: "Lat: %.5f, Lng: %.5f", place.latitude, place.longitude))
                            .font(.caption2)
                            .foregroundColor(.gray)
                        if let userLoc = userLocation {
                            Text("Distance: \(formattedImperialDistance(from: userLoc, to: place.coordinate))")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                }
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

// ---- HELPER FUNCTION DEFINED LAST ----

// Returns "450 ft" or "2.18 mi" for two coordinates.
func formattedImperialDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> String {
    let loc1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)
    let miles = loc1.distance(from: loc2) / 1609.344
    if miles < 0.1 {
        let feet = miles * 5280
        return String(format: "%.0f ft", feet)
    } else {
        return String(format: "%.2f mi", miles)
    }
}
