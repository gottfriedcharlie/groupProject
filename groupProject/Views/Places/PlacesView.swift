// Colin O'Connor
// PlacesView.swift
// groupProject
//
// Prologue: The main view for the Places tab of the app.  It shows all saved places that havent been added to trips yet. From this tab, users can select multiple places to a create a new trip, add individual places to exsisting trips, and delete places they are no longer interested in.
import SwiftUI
struct PlacesView: View {
    @EnvironmentObject var placesViewModel: PlacesViewModel // The view model that manages the collection of saved places
    @EnvironmentObject var tripListViewModel: TripListViewModel // The view used to add places to exsisting trips
    @State private var showingCreateTrip = false
    @State private var selectedPlaces: Set<ItineraryPlace> = [] // Tracks what places are selected by the user
    @State private var editMode: EditMode = .inactive // Controls whether the list is in edit mode or not
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
                    placesList // displays all saved places in a list
                }
                // Adds an action button when places are selected
                if !selectedPlaces.isEmpty {
                    Button(action: { showingCreateTrip = true }) {
                        Label("Create Trip from Selection", systemImage: "airplane")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Places")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode)
            // Creates new trip with the selected places already assigned
            .sheet(isPresented: $showingCreateTrip) {
                AddTripView(
                    viewModel: tripListViewModel,
                    prepopulatedItinerary: Array(selectedPlaces), // adds the selected places to the itinerary
                    onTripCreated: {
                        // Remove the selected places from the saved list since they are now in a trip
                        for place in selectedPlaces {
                            placesViewModel.removePlace(place)
                        }
                        selectedPlaces.removeAll()
                        showingCreateTrip = false
                    }
                )
            }
            // Refreshes the data
            .onAppear {
                placesViewModel.loadPlaces()
            }
        }
    }
    // Creates the scrollable list of saved places with selection and actions
    private var placesList: some View {
        List(selection: $selectedPlaces) {
            ForEach(placesViewModel.savedPlaces) { place in
                HStack {
                    PlaceRowView(place: place)
                    // Adds the + button on each place when not in edit mode
                    if editMode == .inactive {
                        Spacer()
                        Menu {
                            // Creates a item for each exsisting trip
                            ForEach(tripListViewModel.trips) { trip in
                                Button("Add to \(trip.name)") {
                                    // Add place to trip
                                    tripListViewModel.addPlace(place, to: trip)
                                    // Remove from saved places
                                    placesViewModel.removePlace(place)
                                    print("Added to trip and removed from saved places")
                                }
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { // Handles touch interactivity
                    if editMode == .inactive {
                        if selectedPlaces.contains(place) {
                            selectedPlaces.remove(place)
                        } else {
                            selectedPlaces.insert(place)
                        }
                    }
                }
            }
            .onDelete(perform: deletePlaces)
        }
        .listStyle(.insetGrouped)
    }
    // Handles the deletion of places from the saved list
    private func deletePlaces(at offsets: IndexSet) {
        let placesToDelete = offsets.map { placesViewModel.savedPlaces[$0] }
        for place in placesToDelete {
            placesViewModel.removePlace(place)
        }
    }
}
#Preview {
    PlacesView()
        .environmentObject(PlacesViewModel())
        .environmentObject(TripListViewModel())
}
