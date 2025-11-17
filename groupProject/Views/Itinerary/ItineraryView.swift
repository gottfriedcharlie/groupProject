import SwiftUI

/// The Itinerary manager: shows saved places and supports building itineraries/trips from your collection.
struct ItineraryView: View {
    @EnvironmentObject var placesViewModel: PlacesViewModel
    @EnvironmentObject var tripListViewModel: TripListViewModel
    @State private var showingAddPlace = false
    @State private var showingCreateTrip = false
    @State private var selectedPlaces: Set<ItineraryPlace> = []

    var body: some View {
        NavigationView {
            VStack {
                if placesViewModel.savedPlaces.isEmpty {
                    EmptyStateView(
                        icon: "mappin.slash",
                        title: "No Places Yet",
                        message: "Save places from the map to start building trips!"
                    )
                } else {
                    placesList
                }
                actionBar
            }
            .navigationTitle("Itinerary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPlace = true }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlace) {
                AddPlaceView { newPlace in
                    placesViewModel.addPlace(newPlace)
                }
            }
            .sheet(isPresented: $showingCreateTrip) {
                AddTripView(
                    viewModel: tripListViewModel,
                    prepopulatedItinerary: Array(selectedPlaces)
                )
            }
        }
    }

    // MARK: - List of saved places, selection enabled
    private var placesList: some View {
        List(selection: $selectedPlaces) {
            ForEach(placesViewModel.savedPlaces) { place in
                HStack {
                    PlaceRowView(place: place)
                    Spacer()
                    Menu {
                        ForEach(tripListViewModel.trips) { trip in
                            Button("Add to \(trip.name)") {
                                tripListViewModel.addPlace(place, to: trip)
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Toggle selection for building itinerary
                    if selectedPlaces.contains(place) {
                        selectedPlaces.remove(place)
                    } else {
                        selectedPlaces.insert(place)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, .constant(.active)) // Enables multi-select
    }

    // MARK: - Create trip from selected places
    private var actionBar: some View {
        Group {
            if !selectedPlaces.isEmpty {
                Button(action: { showingCreateTrip = true }) {
                    Label("Create Trip from Selection", systemImage: "airplane")
                }
                .padding()
            }
        }
    }
}
