//
//  TripDetailView.swift
//  groupProject
//
//  Created by Charlie Gottfried on 10/24/25.
//

import SwiftUI

struct TripDetailView: View {
    @StateObject private var viewModel: TripDetailViewModel
    @ObservedObject var listViewModel: TripListViewModel
    @State private var showingAddPlace = false
    @State private var showingEditTrip = false
    
    init(trip: Trip, listViewModel: TripListViewModel) {
        _viewModel = StateObject(wrappedValue: TripDetailViewModel(trip: trip))
        self.listViewModel = listViewModel
    }
    
    var body: some View {
        List {
            Section("Trip Info") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.blue)
                        Text(viewModel.trip.destination)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                        Text(viewModel.trip.formattedDateRange)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.green)
                        Text("Budget: $\(viewModel.trip.budget, specifier: "%.0f")")
                            .font(.subheadline)
                    }
                    
                    if !viewModel.trip.description.isEmpty {
                        Divider()
                        Text(viewModel.trip.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section {
                HStack {
                    Text("Places to Visit")
                        .font(.headline)
                    Spacer()
                    Button {
                        showingAddPlace = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if viewModel.places.isEmpty {
                Section {
                    Text("No places added yet")
                        .foregroundColor(.secondary)
                        .italic()
                }
            } else {
                ForEach(PlaceCategory.allCases, id: \.self) { category in
                    let categoryPlaces = viewModel.places(for: category)
                    if !categoryPlaces.isEmpty {
                        Section(category.rawValue) {
                            ForEach(categoryPlaces) { place in
                                PlaceRowView(place: place)
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    viewModel.deletePlace(categoryPlaces[index])
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditTrip = true
                }
            }
        }
        .sheet(isPresented: $showingAddPlace) {
            AddPlaceView(tripId: viewModel.trip.id, viewModel: viewModel)
        }
        .sheet(isPresented: $showingEditTrip) {
            EditTripView(trip: viewModel.trip, listViewModel: listViewModel)
        }
    }
}
