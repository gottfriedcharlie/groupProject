import SwiftUI

struct PlacesView: View {
    @EnvironmentObject var placesViewModel: PlacesViewModel      // Holds [ItineraryPlace]
    @EnvironmentObject var tripListViewModel: TripListViewModel  // For trip creation/add-to-trip logic

    @State private var showingAddPlace = false
    @State private var showingCreateTrip = false
    @State private var selectedPlaces: Set<ItineraryPlace> = []

    var body: some View {
        NavigationView {
            VStack {
                if placesViewModel.savedPlaces.isEmpty {
                    EmptyStateView(
                        icon: "mappin.slash",
                        title: "No Places Saved",
                        message: "Save places from the map or search to start building trips!"
                    )
                } else {
                    placesList
                }
                // Show create trip button if selection is active
                if !selectedPlaces.isEmpty {
                    Button(action: { showingCreateTrip = true }) {
                        Label("Create Trip from Selection", systemImage: "airplane")
                    }
                    .padding()
                }
            }
            .navigationTitle("Places")
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
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Select/deselect for trip creation
                    if selectedPlaces.contains(place) {
                        selectedPlaces.remove(place)
                    } else {
                        selectedPlaces.insert(place)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
