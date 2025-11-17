// TripDetailView.swift
// groupProject
// Created by Clare Morriss

import SwiftUI

// Prologue: detailed view for a single Trip which shows trip info and an editable itinerary
struct TripDetailView: View {
    @StateObject private var viewModel: TripDetailViewModel     // main variable that references the details of the specific trip
    @ObservedObject var listViewModel: TripListViewModel        // this is the reference to the main trip list view model, for updating
    @State private var showingAddPlace = false                  // these state variables allow you to control the modal sheets for
    @State private var showingEditTrip = false                  //       adding places and edting trips

    let tripId: UUID

    // initializer for the view model for this trip, passing parent view model
    init(trip: Trip, listViewModel: TripListViewModel) {
        _viewModel = StateObject(wrappedValue: TripDetailViewModel(trip: trip, parentViewModel: listViewModel))
        self.listViewModel = listViewModel
        self.tripId = trip.id
    }

    var body: some View {
        List {
            Section("Trip Info") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.trip.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(viewModel.trip.destination)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                        Text(viewModel.trip.formattedDateRange)
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
            // itinerary summary and editing
            if viewModel.trip.itinerary.isEmpty {
                Section {
                    Text("No places added yet")
                        .foregroundColor(.secondary)
                        .italic()
                }
            } else {
                Section("Itinerary Summary") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Total Stops", systemImage: "mappin.circle.fill")
                                .font(.subheadline)
                            Spacer()
                            Text("\(viewModel.trip.itinerary.count)")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        HStack {
                            Label("Total Distance", systemImage: "road.lanes")
                            Spacer()
                            Text(viewModel.totalDistanceString)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
                // this is the editable itinerary which drag-reorder, delete, and the ability to add a stop
                Section("Itinerary") {
                    ForEach(Array(viewModel.trip.itinerary.enumerated()), id: \.element.id) { index, place in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(place.name)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Text(place.address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    if let rating = place.rating {
                                        HStack(spacing: 2) {
                                            Image(systemName: "star.fill")
                                                .font(.caption2)
                                                .foregroundColor(.orange)
                                            Text(String(format: "%.1f", rating))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                Spacer()
                                // also the ability to remove a place from itinerary
                                Button(action: {
                                    viewModel.deletePlace(place)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                            }
                            // distance calculator to the next place
                            if let distanceToNext = viewModel.distanceToNext(from: index) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.down")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                    Text("↓ \(String(format: "%.1f km to next", distanceToNext))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.leading, 36)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    // this enables swipe to delete and drag to reorder
                    .onDelete(perform: viewModel.removePlaces)
                    .onMove(perform: viewModel.movePlaces)
                    // Button to add a new place (shows AddPlaceView)
                    Button(action: { showingAddPlace = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Place")
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                EditButton()
                Button(action: { showingEditTrip = true }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showingAddPlace) {     // this is the portion where the modal sheet is used for adding a place
            AddPlaceView { newPlace in
                viewModel.addPlace(newPlace)
            }
        }
        .sheet(isPresented: $showingEditTrip) {     // ditto but for editng the trip
            EditTripView(trip: viewModel.trip, listViewModel: listViewModel)
        }
        .onAppear {
            // this is how you refresh local trip state from list when showing
            if let latestTrip = listViewModel.trips.first(where: { $0.id == tripId }) {
                viewModel.trip = latestTrip
                viewModel.calculateTotalDistance()
            }
        }
        .onDisappear {
            // save trip on leaving which ensures the changes persist
            let updatedTrip = viewModel.trip
            listViewModel.updateTrip(updatedTrip)
        }
    }
}
