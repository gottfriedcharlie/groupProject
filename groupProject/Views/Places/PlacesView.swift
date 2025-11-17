import SwiftUI

struct PlacesView: View {
    @EnvironmentObject var placesViewModel: PlacesViewModel      // Holds [ItineraryPlace]
    @EnvironmentObject var tripListViewModel: TripListViewModel  // For trip creation/add-to-trip logic

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
                // Show create trip button if selection is active
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
                    prepopulatedItinerary: Array(selectedPlaces)
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
                                    tripListViewModel.addPlace(place, to: trip)
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
                    // Only allow selection when not in edit mode
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
