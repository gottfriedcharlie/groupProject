//
//  AddTripView.swift
//  groupProject
//
//   .
//

import SwiftUI

struct AddTripView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TripListViewModel
    
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 7)
    @State private var description = ""
    @State private var budget: Double = 1000
    
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
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trip = Trip(
                            destination: destination,
                            startDate: startDate,
                            endDate: endDate,
                            description: description,
                            budget: budget
                        )
                        viewModel.addTrip(trip)
                        dismiss()
                    }
                    .disabled(destination.isEmpty)
                }
            }
        }
    }
}
