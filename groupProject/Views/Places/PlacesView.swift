import SwiftUI

struct PlacesView: View {
    @EnvironmentObject var placesViewModel: PlacesViewModel
    @EnvironmentObject var tripListViewModel: TripListViewModel

    @State private var showingCreateTrip = false
    @State private var selectedPlaces: Set<ItineraryPlace> = []
    @State private var editMode: EditMode = .inactive

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
            .sheet(isPresented: $showingCreateTrip) {
                AddTripView(
                    viewModel: tripListViewModel,
                    prepopulatedItinerary: Array(selectedPlaces),
                    onTripCreated: {
                        // Delete selected places from saved places after trip creation
                        for place in selectedPlaces {
                            placesViewModel.removePlace(place)
                        }
                        selectedPlaces.removeAll()
                        showingCreateTrip = false
                    }
                )
            }
            .onAppear {
                placesViewModel.loadPlaces()
            }
        }
    }

    private var placesList: some View {
        List(selection: $selectedPlaces) {
            ForEach(placesViewModel.savedPlaces) { place in
                HStack {
                    PlaceRowView(place: place)
                    
                    if editMode == .inactive {
                        Spacer()
                        Menu {
                            ForEach(tripListViewModel.trips) { trip in
                                Button("Add to \(trip.name)") {
                                    // Add place to trip
                                    tripListViewModel.addPlace(place, to: trip)
                                    // Remove from saved places
                                    placesViewModel.removePlace(place)
                                    print("✅ Added to trip and removed from saved places")
                                }
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
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
