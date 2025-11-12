import SwiftUI

struct TripDetailView: View {
    @StateObject private var viewModel: TripDetailViewModel
    @ObservedObject var listViewModel: TripListViewModel
    @State private var showingAddPlace = false
    @State private var showingEditTrip = false
    
    let tripId: UUID  // Add this to track which trip we're editing
    
    init(trip: Trip, listViewModel: TripListViewModel) {
        _viewModel = StateObject(wrappedValue: TripDetailViewModel(trip: trip))
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
                                    saveChanges()  // Save after deleting
                                }
                            }
                        }
                    }
                }
            }
            Section(header: Text("Places")) {
                ForEach(viewModel.places) { place in
                    VStack(alignment: .leading) {
                        Text(place.name).font(.headline)
                        Text(place.address).font(.subheadline).foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: viewModel.removePlaces)
                .onMove(perform: viewModel.movePlaces)
            }
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
        }
        .sheet(isPresented: $showingAddPlace) {
            AddPlaceView { newPlace in
                viewModel.addPlace(newPlace)
                saveChanges()  // Save after adding
            }
        }
        .sheet(isPresented: $showingEditTrip) {
            EditTripView(trip: viewModel.trip, listViewModel: listViewModel)
        }
        .onDisappear {
            saveChanges()  // Save when leaving the view
        }
    }
    
    // Add this helper function
    private func saveChanges() {
        listViewModel.updateTrip(viewModel.trip)
    }

}
