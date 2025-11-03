//
//  ItineraryView.swift
//  groupProject
//

import SwiftUI

struct ItineraryView: View {
    @StateObject private var viewModel = ItineraryViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.itineraryPlaces.isEmpty {
                    EmptyStateView(
                        icon: "map.circle",
                        title: "No Places Added",
                        message: "Search for places on the map to add them to your itinerary!"
                    )
                } else {
                    itineraryList
                }
            }
            .navigationTitle("My Itinerary")
            .toolbar {
                if !viewModel.itineraryPlaces.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear", action: {
                            viewModel.clearItinerary()
                        })
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private var itineraryList: some View {
        List {
            ForEach(viewModel.itineraryPlaces) { place in
                ItineraryPlaceRow(place: place) {
                    viewModel.removePlace(place)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.removePlace(viewModel.itineraryPlaces[index])
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct ItineraryPlaceRow: View {
    let place: ItineraryPlace
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(place.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            
            Text(place.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let rating = place.rating {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                    if let total = place.userRatingsTotal {
                        Text("(\(total) reviews)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let phone = place.phoneNumber, !phone.isEmpty {
                Text(phone)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ItineraryView()
}
