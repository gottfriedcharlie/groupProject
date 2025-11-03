//
//  MapSearchView.swift
//  groupProject
//

import SwiftUI
import MapKit

struct MapSearchView: View {
    @ObservedObject var viewModel: MapSearchViewModel
    @Environment(\.dismiss) var dismiss
    let onAddPlace: (GooglePlacesResult, PlaceCategory) -> Void
    @State private var selectedResult: GooglePlacesResult?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText, onSearch: {
                    viewModel.searchNearby(query: viewModel.searchText)
                })
                .padding()
                
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                    .padding()
                }
                
                if viewModel.isLoading {
                    LoadingView()
                        .frame(maxHeight: .infinity)
                } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Results Found")
                            .font(.headline)
                        Text("Try searching for different keywords")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults) { result in
                        SearchResultRow(result: result) {
                            selectedResult = result
                        }
                    }
                    .listStyle(.plain)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "map")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Search for Places")
                            .font(.headline)
                        Text("Search for restaurants, museums, parks, and more near you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                    .padding()
                }
            }
            .navigationTitle("Find Places")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $selectedResult) { result in
            PlaceDetailSheet(
                place: result,
                onAdd: {
                    let category = viewModel.categorizePlace(result)
                    onAddPlace(result, category)
                    dismiss()
                }
            )
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearch: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search ice cream, museums, restaurants...", text: $text)
                .textInputAutocapitalization(.none)
                .onSubmit(onSearch)
            
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
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(result.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    if let rating = result.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            Text(String(format: "%.1f", rating))
                                .font(.caption2)
                                .foregroundColor(.primary)
                            if let total = result.userRatingsTotal {
                                Text("(\(total))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
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
    @Environment(\.dismiss) var dismiss
    let onAdd: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Name
                        Text(place.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Address
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.red)
                            Text(place.address)
                                .font(.body)
                        }
                        
                        Divider()
                        
                        // Rating
                        if let rating = place.rating {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rating")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                HStack(spacing: 8) {
                                    HStack(spacing: 2) {
                                        ForEach(0..<5, id: \.self) { index in
                                            Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    Text(String(format: "%.1f", rating))
                                        .fontWeight(.semibold)
                                    if let total = place.userRatingsTotal {
                                        Text("(\(total) reviews)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Divider()
                        }
                        
                        // Phone
                        if let phone = place.phoneNumber, !phone.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Phone")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Link(phone, destination: URL(string: "tel:\(phone)")!)
                                    .foregroundColor(.blue)
                            }
                            
                            Divider()
                        }
                        
                        // Types
                        if !place.placeTypes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Type")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                HStack(spacing: 8) {
                                    ForEach(place.placeTypes.prefix(3), id: \.self) { type in
                                        Text(type.capitalized)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(8)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // Add to Itinerary Button
                Button(action: onAdd) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add to Itinerary")
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
                    Button("Close") {
                        dismiss()
                    }
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
