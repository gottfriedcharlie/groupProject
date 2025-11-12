import SwiftUI
import CoreLocation

struct AddTripView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TripListViewModel
    var prepopulatedItinerary: [ItineraryPlace]? = nil

    @State private var name = ""
    @State private var destination = ""
    @State private var destinationCoordinate: CLLocationCoordinate2D?
    @State private var showingDestinationSearch = false
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 7)
    @State private var description = ""
    @State private var budget: Double = 1000
    @State private var itinerary: [ItineraryPlace] = []

    init(viewModel: TripListViewModel, prepopulatedItinerary: [ItineraryPlace]? = nil) {
        self.viewModel = viewModel
        self.prepopulatedItinerary = prepopulatedItinerary
        if let prepopulatedItinerary {
            _itinerary = State(initialValue: prepopulatedItinerary)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Trip Details") {
                    TextField("Trip Name", text: $name)
                    Button(action: { showingDestinationSearch = true }) {
                        HStack {
                            Text("Destination").foregroundColor(.primary)
                            Spacer()
                            if destination.isEmpty {
                                Text("Select location").foregroundColor(.gray)
                            } else {
                                Text(destination).foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
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
                // ---- Pre-populated Itinerary ----
                if !itinerary.isEmpty {
                    Section("Pre-populated Itinerary") {
                        ForEach(itinerary) { place in
                            Text(place.name)
                        }
                    }
                }
            }
            .navigationTitle("Create Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trip = Trip(
                            name: name,
                            destination: destination,
                            destinationLatitude: destinationCoordinate?.latitude,
                            destinationLongitude: destinationCoordinate?.longitude,
                            startDate: startDate,
                            endDate: endDate,
                            description: description,
                            budget: budget,
                            itinerary: itinerary // <-- Best: use an array here!
                        )
                        viewModel.addTrip(trip)
                        dismiss()
                    }
                    .disabled(name.isEmpty || destination.isEmpty)
                }
            }
            .sheet(isPresented: $showingDestinationSearch) {
                MapSearchView(
                    viewModel: MapSearchViewModel(),
                    onAddPlace: { result, category in
                        destination = result.name
                        destinationCoordinate = CLLocationCoordinate2D(
                            latitude: result.latitude,
                            longitude: result.longitude
                        )
                        showingDestinationSearch = false
                    }
                )
            }
        }
    }
}
