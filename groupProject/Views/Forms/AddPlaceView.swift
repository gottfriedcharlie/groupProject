import SwiftUI

struct AddPlaceView: View {
    var onSave: (ItineraryPlace) -> Void
    @Environment(\.dismiss) var dismiss
    @StateObject private var searchViewModel = MapSearchViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                PlaceSearchBar(text: $searchText, onSearch: {
                    searchViewModel.searchNearby(query: searchText)
                })
                
                if searchViewModel.isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else if searchViewModel.searchResults.isEmpty && !searchText.isEmpty {
                    Text("No places found")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(searchViewModel.searchResults) { place in
                        Button(action: {
                            onSave(ItineraryPlace(from: place))
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.name)
                                    .font(.headline)
                                Text(place.address)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
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

struct PlaceSearchBar: View {
    @Binding var text: String
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
