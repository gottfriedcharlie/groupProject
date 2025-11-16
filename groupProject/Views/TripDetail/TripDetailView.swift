import SwiftUI

// Detailed view for a single Trip: shows trip info and editable itinerary.
struct TripDetailView: View {
    // Main state object for trip detail logic.
    @StateObject private var viewModel: TripDetailViewModel
    // Reference to main trip list view model, for updating trips.
    @ObservedObject var listViewModel: TripListViewModel
    // Control Add Place and Edit Trip modal sheets
    @State private var showingAddPlace = false
    @State private var showingEditTrip = false

    // ID of the trip being displayed
    let tripId: UUID

    // Initialize view model for this trip, passing parent
    init(trip: Trip, listViewModel: TripListViewModel) {
        _viewModel = StateObject(wrappedValue: TripDetailViewModel(trip: trip, parentViewModel: listViewModel))
        self.listViewModel = listViewModel
        self.tripId = trip.id
    }

    var body: some View {
        List {
            // MARK: - Trip Info Section
            Section("Trip Info") {
                VStack(alignment: .leading, spacing: 12) {
                    // Trip Title/Location
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
                    // Date Range
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                        Text(viewModel.trip.formattedDateRange)
                            .font(.subheadline)
                    }
                    // Optional Description
                    if !viewModel.trip.description.isEmpty {
                        Divider()
                        Text(viewModel.trip.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            // MARK: - Itinerary Summary & Editing
            if viewModel.trip.itinerary.isEmpty {
                Section {
                    Text("No places added yet")
                        .foregroundColor(.secondary)
                        .italic()
                }
            } else {
                // High-level summary (number of stops, etc.)
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
                // Editable Itinerary: drag-reorder, delete, add stop
                Section("Itinerary") {
                    ForEach(Array(viewModel.trip.itinerary.enumerated()), id: \.element.id) { index, place in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                // Number badge
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                // Place details
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
                                // Remove this stop from itinerary
                                Button(action: {
                                    viewModel.deletePlace(place)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                            }
                            // Distance to next
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
                    // Enable swipe to delete and drag to reorder
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
        // MARK: - Navigation and Toolbars
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                EditButton()
                Button(action: { showingEditTrip = true }) {
                    Image(systemName: "square.and.pencil") // Edit trip metadata
                }
            }
        }
        // MARK: - Sheet Modals for Adding/Editing
        .sheet(isPresented: $showingAddPlace) {
            AddPlaceView { newPlace in
                viewModel.addPlace(newPlace)
            }
        }
        .sheet(isPresented: $showingEditTrip) {
            EditTripView(trip: viewModel.trip, listViewModel: listViewModel)
        }
        // MARK: - Sync State on Appear/Disappear
        .onAppear {
            // Always refresh local trip state from list when showing
            if let latestTrip = listViewModel.trips.first(where: { $0.id == tripId }) {
                viewModel.trip = latestTrip
                viewModel.calculateTotalDistance()
            }
        }
        .onDisappear {
            // Save trip on leaving - ensures changes persistable
            let updatedTrip = viewModel.trip
            listViewModel.updateTrip(updatedTrip)
        }
    }
}
