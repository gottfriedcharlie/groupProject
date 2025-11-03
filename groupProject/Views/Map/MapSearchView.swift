//
//  MapSearchView.swift
//  groupProject
//
//  Created by Charlie Gottfried on 11/3/25.
//

import SwiftUI
import MapKit

struct MapSearchView: View {
    @ObservedObject var viewModel: MapSearchViewModel
    @Environment(\.dismiss) var dismiss
    let onAddPlace: (GooglePlacesResult, PlaceCategory) -> Void
    
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
                            let category = viewModel.categorizePlace(result)
                            onAddPlace(result, category)
                            dismiss()
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
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.body)
                    .fontWeight(.medium)
                
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
                        if let total = result.userRatingsTotal {
                            Text("(\(total))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 8)
    }
}

#Preview {
    MapSearchView(
        viewModel: MapSearchViewModel(),
        onAddPlace: { _, _ in }
    )
}
