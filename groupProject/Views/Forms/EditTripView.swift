// EditTripView.swift
// groupProject
// Created by Clare Morriss

import SwiftUI

// Prologue: this is a modal form for editing the details of an existing trip
// Swift documentation and AI was used to help with our understanding of modal forms and their structure & set up
struct EditTripView: View {
    @Environment(\.dismiss) var dismiss     // this controls the dismissal of the edit modal
    @ObservedObject var listViewModel: TripListViewModel    // reference to the TripListViewModel for updates after editing
    
    // these state variables are for each editable field, which are prepopulated from current trip
    @State private var name: String
    @State private var destination: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var description: String
    
    private let tripId: UUID
    
    // custom initializer which copies the current trip's fields into state variables
    init(trip: Trip, listViewModel: TripListViewModel) {
        self.tripId = trip.id
        self.listViewModel = listViewModel
        _name = State(initialValue: trip.name)
        _destination = State(initialValue: trip.destination)
        _startDate = State(initialValue: trip.startDate)
        _endDate = State(initialValue: trip.endDate)
        _description = State(initialValue: trip.description)
    }
    
    // this section is for edits to the destination, dates, description & then opens up to a larger edit of the trips itinerary
    var body: some View {
        NavigationView {
            Form {
                Section("Destination") {
                    TextField("Where are you going?", text: $destination)
                }
                Section("Dates") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
            }
            // cancel & save edited trip info
            .navigationTitle("Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // essentially you 'build' an updated Trip with all the new info and push changes to the view model from above
                        let updatedTrip = Trip(
                            id: tripId,
                            name: name,
                            destination: destination,
                            startDate: startDate,
                            endDate: endDate,
                            description: description
                        )
                        listViewModel.updateTrip(updatedTrip)
                        dismiss()
                    }
                    .disabled(destination.isEmpty) // you cannot save the trip if the destination is empty
                }
            }
        }
    }
}
