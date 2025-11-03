//
//  AddPlaceView.swift
//  groupProject
//
//   .
//

import SwiftUI

struct AddPlaceView: View {
    @Environment(\.dismiss) var dismiss
    let tripId: UUID
    @ObservedObject var viewModel: TripDetailViewModel
    
    @State private var name = ""
    @State private var category: PlaceCategory = .restaurant
    @State private var notes = ""
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Place Info") {
                    TextField("Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(PlaceCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
                
                Section("Location") {
                    HStack {
                        Text("Latitude")
                        Spacer()
                        TextField("0.0", value: $latitude, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Longitude")
                        Spacer()
                        TextField("0.0", value: $longitude, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Add Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let place = Place(
                            name: name,
                            category: category,
                            latitude: latitude,
                            longitude: longitude,
                            notes: notes,
                            tripId: tripId
                        )
                        viewModel.addPlace(place)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
