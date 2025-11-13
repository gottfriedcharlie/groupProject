import SwiftUI

struct TripListView: View {
    // USE the shared view model from environment instead of creating a new one
    @EnvironmentObject var viewModel: TripListViewModel
    @State private var showingAddTrip = false

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.filteredTrips.isEmpty {
                    EmptyStateView(
                        icon: "airplane.departure",
                        title: "No Trips Yet",
                        message: "Start planning your next adventure!"
                    )
                } else {
                    tripsList
                }
            }
            .navigationTitle("My Trips")
            .toolbar {
                // "Create New Trip" (plus button) at top right
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
                ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Filter", selection: $viewModel.filterOption) {
                            Text("All").tag(TripFilter.all)
                            Text("Upcoming").tag(TripFilter.upcoming)
                            Text("Past").tag(TripFilter.past)
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search trips")
            .sheet(isPresented: $showingAddTrip) {
                AddTripView(viewModel: viewModel)
            }
            .onAppear {
                // Reload trips when view appears
                print("🔄 TripListView appeared - reloading trips")
                viewModel.loadTrips()
            }
        }
    }

    private var tripsList: some View {
        List {
            ForEach(viewModel.filteredTrips) { trip in
                NavigationLink(
                    destination: TripDetailView(trip: trip, listViewModel: viewModel)
                ) {
                    TripCardView(trip: trip)
                }
            }
            .onDelete(perform: deleteTrips)
        }
        .listStyle(.insetGrouped)
        .refreshable {
            // Pull to refresh
            viewModel.loadTrips()
        }
    }

    private func deleteTrips(at offsets: IndexSet) {
        let tripsToDelete = offsets.map { viewModel.filteredTrips[$0] }
        for trip in tripsToDelete {
            viewModel.deleteTrip(trip)
        }
    }
}

#Preview {
    TripListView()
        .environmentObject(TripListViewModel())
}
