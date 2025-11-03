//
//  TripListView.swift
//  groupProject
//
//   .
//

import SwiftUI

struct TripListView: View {
    @StateObject private var viewModel = TripListViewModel()
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTrip = true
                    } label: {
                        Image(systemName: "plus")
                    }
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
        }
    }
    
    private var tripsList: some View {
        List {
            ForEach(viewModel.filteredTrips) { trip in
                NavigationLink(destination: TripDetailView(trip: trip, listViewModel: viewModel)) {
                    TripCardView(trip: trip)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    let trip = viewModel.filteredTrips[index]
                    viewModel.deleteTrip(trip)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
