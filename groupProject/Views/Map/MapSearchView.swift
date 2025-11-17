//
//  MapSearchView.swift
//  groupProject
//  Created by Charlie Gottfried
//The search interface. Type what you're looking for (restaurant, museum, coffee shop), see results with ratings and addresses. Tap one to view full details before saving.

import SwiftUI
import CoreLocation

struct MapSearchView: View {
    @ObservedObject var viewModel: MapSearchViewModel
    let onAddPlace: (GooglePlacesResult, PlaceCategory) -> Void
    @State private var selectedResult: GooglePlacesResult?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $viewModel.searchText)
                    .padding()
                    .onChange(of: viewModel.searchText) { oldValue, newValue in
                        // only search after 3 chars to avoid too many api calls
                        if newValue.count >= 3 {
                            viewModel.searchNearby(query: newValue)
                        }
                    }
                
                // Error message display
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                }
                
                // Loading state with spinner
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Searching...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }
                // No results state
                else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Results Found")
                            .font(.headline)
                        
                        Text("Try searching for different keywords")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }
                // Results list - shows all places from google api
                else if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults) { result in
                        SearchResultRow(
                            result: result,
                            userLocation: viewModel.userLocation,
                            onTap: { selectedResult = result }
                        )
                    }
                    .listStyle(.plain)
                }
                // Empty state before searching
                else {
                    VStack(spacing: 12) {
                        Image(systemName: "map")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Search for Places")
                            .font(.headline)
                        
                        Text("Search for restaurants, museums, parks, and more")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
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
        //detail sheet when user taps a search result
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

// Search bar component - reusable
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search places...", text: $text)
                .textInputAutocapitalization(.none)
            
            //clear button when theres text
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

// Search result row - shows each place in the list
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
                    
                    // rating and distance info in compact row
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
                        //shows distance from current location or search center
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
            .padding(.vertical, 8)
        }
    }
}

// Place detail sheet - full info about a place
struct PlaceDetailSheet: View {
    let place: GooglePlacesResult
    let userLocation: CLLocationCoordinate2D?
    let onAdd: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(place.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            //rating display with stars
            if let rating = place.rating {
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", rating))
                            .fontWeight(.semibold)
                        if let total = place.userRatingsTotal {
                            Text("(\(total) reviews)")
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            // phone number if available
            if let phoneNumber = place.phoneNumber {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.blue)
                    Text(phoneNumber)
                        .font(.subheadline)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: onAdd) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add to Trip")
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
    }
}

// Helper function to format distance in miles
// ai helped write this conversion from meters to miles
func formattedImperialDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> String {
    let loc1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)
    let distanceInMeters = loc1.distance(from: loc2)
    let distanceInMiles = distanceInMeters / 1609.344
    return String(format: "%.1f mi", distanceInMiles)
}

#Preview {
    MapSearchView(
        viewModel: MapSearchViewModel(),
        onAddPlace: { _, _ in }
    )
}
