import SwiftUI

struct TripDetailView: View {
    @StateObject private var viewModel: TripDetailViewModel
    @ObservedObject var listViewModel: TripListViewModel
    @State private var showingAddPlace = false
    @State private var showingEditTrip = false
    
    let tripId: UUID
    
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
            
            // MARK: - Check what we have
            if viewModel.trip.itinerary.isEmpty {
                Section {
                    Text("No places added yet")
                        .foregroundColor(.secondary)
                        .italic()
                }
            } else {
                // MARK: - Itinerary Summary Section
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
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "%.1f km", viewModel.totalDistance))
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Itinerary Section
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
                                
                                // Place info
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
                                
                                // Delete button
                                Button(action: {
                                    viewModel.deletePlace(place)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                            }
                            
                            // Distance to next location
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
                    .onDelete(perform: viewModel.removePlaces)
                    .onMove(perform: viewModel.movePlaces)
                }
            }
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                EditButton()
                
                if !viewModel.trip.itinerary.isEmpty {
                    Button(action: { showingAddPlace = true }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddPlace) {
            AddPlaceView { newPlace in
                viewModel.addPlace(newPlace)
            }
        }
        .sheet(isPresented: $showingEditTrip) {
            EditTripView(trip: viewModel.trip, listViewModel: listViewModel)
        }
        .onAppear {
            // Refresh the trip data when view appears
            if let latestTrip = listViewModel.trips.first(where: { $0.id == tripId }) {
                viewModel.trip = latestTrip
                viewModel.calculateTotalDistance()
            }
        }
        .onDisappear {
            let updatedTrip = viewModel.trip
            listViewModel.updateTrip(updatedTrip)
        }
        
    }
}
