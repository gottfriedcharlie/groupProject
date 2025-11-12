import SwiftUI

// Displays the user's itinerary as a list of saved places.
// Allows adding a new trip and lets you add places to any trip.
struct ItineraryView: View {
    @StateObject private var viewModel = ItineraryViewModel()
    @EnvironmentObject var tripListViewModel: TripListViewModel
    @State private var showingAddTrip = false

    // State for trip picker modal and tracking which place to add
    @State private var showingTripPicker: Bool = false
    @State private var placeToAdd: ItineraryPlace? = nil

    var body: some View {
        NavigationView {
            ZStack {
                // If no places have been added, show an empty state view
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
                // "+" button to add a new trip
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTrip = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Trip")
                        }
                    }
                }
                // Edit button for reordering/removing places
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            // Sheet for adding a new trip (prepopulated with current itinerary places)
            .sheet(isPresented: $showingAddTrip) {
                AddTripView(
                    viewModel: tripListViewModel,
                    prepopulatedItinerary: viewModel.itineraryPlaces
                )
            }
            // Sheet for picking which trip to add a place to
            .sheet(isPresented: $showingTripPicker) {
                TripPickerSheet(
                    trips: tripListViewModel.trips,
                    onPick: { pickedTrip in
                        if let placeToAdd = placeToAdd {
                            tripListViewModel.addPlaceToTrip(placeToAdd, toTrip: pickedTrip.id)
                        }
                        showingTripPicker = false
                    }
                )
            }
        }
    }

    // Renders the itinerary places as a list with support for delete, move, and add-to-trip actions.
    private var itineraryList: some View {
        List {
            ForEach(viewModel.itineraryPlaces, id: \.id) { place in
                ItineraryPlaceRow(place: place) {
                    viewModel.removePlace(place)
                }
                .swipeActions(edge: .trailing) {
                    // Delete action
                    Button(role: .destructive) {
                        viewModel.removePlace(place)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    // Add to Trip action: opens the trip picker
                    Button {
                        placeToAdd = place
                        showingTripPicker = true
                    } label: {
                        Label("Add to Trip", systemImage: "plus.circle")
                    }
                    .tint(.blue)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.removePlace(viewModel.itineraryPlaces[index])
                }
            }
            .onMove(perform: viewModel.movePlaces)
        }
        .listStyle(.insetGrouped)
    }
}

// Shows details about an individual itinerary place.
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

// Sheet/modal: Pick which trip to add a place to
struct TripPickerSheet: View {
    let trips: [Trip]
    let onPick: (Trip) -> Void

    var body: some View {
        NavigationView {
            List(trips) { trip in
                Button(trip.name) {
                    onPick(trip)
                }
            }
            .navigationTitle("Select Trip")
        }
    }
}
