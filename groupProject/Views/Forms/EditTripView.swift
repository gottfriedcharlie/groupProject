//
//  EditTripView.swift
//  groupProject
//
//   .
//

import SwiftUI

struct EditTripView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var listViewModel: TripListViewModel
    
    @State private var name: String
    @State private var destination: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var description: String
    @State private var budget: Double
    
    private let tripId: UUID
    
    init(trip: Trip, listViewModel: TripListViewModel) {
        self.tripId = trip.id
        self.listViewModel = listViewModel
        _name = State(initialValue: trip.name)
        _destination = State(initialValue: trip.destination)
        _startDate = State(initialValue: trip.startDate)
        _endDate = State(initialValue: trip.endDate)
        _description = State(initialValue: trip.description)
        _budget = State(initialValue: trip.budget)
    }
    
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
                
                Section("Budget") {
                    HStack {
                        Text("$")
                        TextField("Amount", value: $budget, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
            }
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
                        let updatedTrip = Trip(
                            id: tripId,
                            name: name,
                            destination: destination,
                            startDate: startDate,
                            endDate: endDate,
                            description: description,
                            budget: budget
                        )
                        listViewModel.updateTrip(updatedTrip)
                        dismiss()
                    }
                    .disabled(destination.isEmpty)
                }
            }
        }
    }
}
