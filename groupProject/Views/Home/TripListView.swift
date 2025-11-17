// TripListView.swift
// groupProject
// Created by Clare Morriss

import SwiftUI

// Prologue: this is the main view for the Trips tab which lists all trips, includes filtering, searching, and creating new trips
struct TripListView: View {
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
                } else {    // if there are trips planned just display them instead of the message above
                    tripsList
                }
            }
            .navigationTitle("My Trips")
            .toolbar {
                // button for creating new trips
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
                // this allows for native SwiftUI list editing mode for deletion
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                // this filtering menu lets the user narrow trips by status (all/upcoming/past)
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
            // this just checks if the trip is being searched for & if true, is displayed
            .searchable(text: $viewModel.searchText, prompt: "Search trips")
            .sheet(isPresented: $showingAddTrip) {
                AddTripView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadTrips()
            }
        }
    }

    // this is the list of trip cards with navigation and swipe-to-delete support, which is also scrollable
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
        .refreshable { viewModel.loadTrips() }
    }

    // this removes the selected trips from the view model and persists changes if they are deleted
    private func deleteTrips(at offsets: IndexSet) {
        let tripsToDelete = offsets.map { viewModel.filteredTrips[$0] }
        for trip in tripsToDelete {
            viewModel.deleteTrip(trip)
        }
    }
}
