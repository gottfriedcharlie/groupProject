import SwiftUI

// Enhanced ItineraryView - shows saved trips and allows building itinerary for each
struct ItineraryView: View {
    @EnvironmentObject var itineraryViewModel: ItineraryViewModel
    @EnvironmentObject var tripListViewModel: TripListViewModel
    @State private var showingAddTrip = false
    @State private var navigationPath: [Trip] = []  // NEW: Navigation path

    var body: some View {
        NavigationStack(path: $navigationPath) {  // NEW: Use NavigationStack
            ZStack {
                if tripListViewModel.trips.isEmpty {
                    EmptyStateView(
                        icon: "airplane.departure",
                        title: "No Trips Yet",
                        message: "Create a trip first to build an itinerary"
                    )
                } else {
                    tripsList
                }
            }
            .navigationTitle("My Trips")
            .navigationDestination(for: Trip.self) { trip in
                ItineraryBuilderView(trip: trip)
                    .environmentObject(itineraryViewModel)
                    .environmentObject(tripListViewModel)
            }
            .toolbar {
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
            }
            .sheet(isPresented: $showingAddTrip) {
                AddTripView(viewModel: tripListViewModel)
            }
        }
    }

    private var tripsList: some View {
        List {
            ForEach(tripListViewModel.trips) { trip in
                VStack(alignment: .leading, spacing: 12) {
                    // Trip header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trip.name)
                                .font(.headline)
                                .fontWeight(.bold)
                            Text(trip.destination)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if trip.isUpcoming {
                            Label("Upcoming", systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Itinerary info
                    HStack(spacing: 16) {
                        Label("\(trip.itinerary.count) places", systemImage: "mappin")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label(trip.formattedDateRange, systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Build/View itinerary button
                    NavigationLink(value: trip) {
                        HStack {
                            Image(systemName: trip.itinerary.isEmpty ? "plus.circle" : "pencil.circle")
                            Text(trip.itinerary.isEmpty ? "Build Itinerary" : "Edit Itinerary")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                        .font(.caption)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    ItineraryView()
        .environmentObject(TripListViewModel())
        .environmentObject(ItineraryViewModel())
}
