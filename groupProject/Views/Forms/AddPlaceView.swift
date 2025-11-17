// Colin O'Connor
// AddPlaceView.swift
// groupProject
//
// Prologue: A view that allows for users to search for, save, and add places to trips. It does this by creating a functioning search bar that uses the Google Places API for the search function.
import SwiftUI

struct AddPlaceView: View {
    var onSave: (ItineraryPlace) -> Void // Calls back to the parent view to handle the selected place when the user successfully adds a place.
    @Environment(\.dismiss) var dismiss
    @StateObject private var searchViewModel = MapSearchViewModel() // Handles the Google places search
    @State private var searchText = "" // Stores the text that is currently in the search field as the user is typing

    var body: some View {
        NavigationView {
            VStack {
                // Create the search bar UI
                PlaceSearchBar(text: $searchText, onSearch: {
                    searchViewModel.searchNearby(query: searchText)
                })
                
                // While the API request is loading show the apples spinning symbol
                if searchViewModel.isLoading {
                    ProgressView("Searching...")
                        .padding()
                // Return "No places found" if the search results are empty
                } else if searchViewModel.searchResults.isEmpty && !searchText.isEmpty {
                    Text("No places found")
                        .foregroundColor(.secondary)
                        .padding()
                // Display search results
                } else {
                    // Each results works as an interactible button
                    List(searchViewModel.searchResults) { place in
                        Button(action: {
                            onSave(ItineraryPlace(from: place)) // Converts the Google places result into the Itinerary Place format from PlacesViewModel
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.name)
                                    .font(.headline)
                                Text(place.address)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                // Optional that displays rating if it is availible
                                if let rating = place.rating {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        Text(String(format: "%.1f", rating))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Spacer()
            }
            // After 3 characters are typed automatically provide search results
            .onChange(of: searchText) { oldValue, newValue in
                if newValue.count >= 3 {
                    searchViewModel.searchNearby(query: newValue)
                }
            }
            .navigationTitle("Add Place")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Search Bar component
struct PlaceSearchBar: View {
    @Binding var text: String // @Binding makes it so changes in this view update the parent view automatically
    var onSearch: () -> Void
    var body: some View {
        HStack {
            TextField("Search for a place", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearch()
                }
            
            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
            }
            .disabled(text.isEmpty)
        }
        .padding()
    }
}
