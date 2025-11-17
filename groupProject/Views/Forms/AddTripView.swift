// AddTripView.swift
// groupProject
// Created by Clare Morriss

import SwiftUI
import CoreLocation

// Prologue: modal sheet for creating a new trip, with the optional for a prepopulated itinerary
// Swift documentation and AI was used to help with our understanding of modal forms and their structure & set up

struct AddTripView: View {
    @Environment(\.dismiss) var dismiss                   // dismissal control for the sheet/modal
    @ObservedObject var viewModel: TripListViewModel      // can add the new trip to TripListViewModel
    var prepopulatedItinerary: [ItineraryPlace]? = nil    // optional var where if it is not prepopulated, then null
    var onTripCreated: (() -> Void)? = nil                // closure run after successfully creating a trip (for UI updates, etc)

    // state variables which hold user input from the form fields
    @State private var name = ""
    @State private var destination = ""
    @State private var destinationCoordinate: CLLocationCoordinate2D?
    @State private var showingDestinationSearch = false
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 7) // default to 1-week trip
    @State private var description = ""
    @State private var itinerary: [ItineraryPlace] = []
    @StateObject private var locationManager = LocationManagerViewModel()

    // custom initializer to allow for optional prepopulated itinerary and creation callback to the prepopulated itinerary
    init(viewModel: TripListViewModel, prepopulatedItinerary: [ItineraryPlace]? = nil, onTripCreated: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.prepopulatedItinerary = prepopulatedItinerary
        self.onTripCreated = onTripCreated
        // If there is a prepopulated itinerary, initialize the @State with it
        if let prepopulatedItinerary {
            _itinerary = State(initialValue: prepopulatedItinerary)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                // required info: trip name and destination
                Section("Trip Details") {
                    TextField("Trip Name", text: $name)
                    Section {
                        // this button launches a location picker/search modal when clicked
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
                        // this button lets the user fill the destination from current location
                        Button(action: useCurrentLocation) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                Text("Use Current Location")
                                    .foregroundColor(.blue)
                            }
                        }
                    } header: {
                        Text("Choose Destination")
                    }
                }
                // choosing a start & end date for the trip
                Section("Dates") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                // longer description field
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                // show pre-filled itinerary places if any
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
                // save button creates the new Trip and add to the master list, if required fields are populated
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
                            itinerary: itinerary
                        )
                        viewModel.addTrip(trip)
                        onTripCreated?()
                        dismiss()
                    }
                    .disabled(name.isEmpty || destination.isEmpty)
                }
            }
            // modal for destination searching/picking
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
            // requests current location when view appears
            .onAppear {
                locationManager.requestLocation()
            }
        }
    }
    
    // helper function to set destination to the user's current device location
    private func useCurrentLocation() {
        guard let userLoc = locationManager.userLocation else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)) { placemarks, error in
            if let placemark = placemarks?.first {
                destination = placemark.locality ?? placemark.administrativeArea ?? "Current Location"
                destinationCoordinate = userLoc
            } else {
                destination = "Current Location"
                destinationCoordinate = userLoc
            }
        }
    }
}
