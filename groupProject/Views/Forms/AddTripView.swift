import SwiftUI
import CoreLocation

// Modal sheet for creating a new trip, optionally prepopulated with an itinerary.
struct AddTripView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TripListViewModel
    var prepopulatedItinerary: [ItineraryPlace]? = nil
    var onTripCreated: (() -> Void)? = nil

    @State private var name = ""
    @State private var destination = ""
    @State private var destinationCoordinate: CLLocationCoordinate2D?
    @State private var showingDestinationSearch = false
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 7)
    @State private var description = ""
    @State private var itinerary: [ItineraryPlace] = []
    
    @StateObject private var locationManager = LocationManagerViewModel()

    init(viewModel: TripListViewModel, prepopulatedItinerary: [ItineraryPlace]? = nil, onTripCreated: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.prepopulatedItinerary = prepopulatedItinerary
        self.onTripCreated = onTripCreated
        if let prepopulatedItinerary {
            _itinerary = State(initialValue: prepopulatedItinerary)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Trip Details") {
                    TextField("Trip Name", text: $name)
                    
                    Section {
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
                        
                        // Button to use current location
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
                
                Section("Dates") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
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
                            itinerary: itinerary
                        )
                        viewModel.addTrip(trip)
                        onTripCreated?()
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
            .onAppear {
                locationManager.requestLocation()
            }
        }
    }
    
    // Use current location as destination
    private func useCurrentLocation() {
        guard let userLoc = locationManager.userLocation else {
            return
        }
        
        // Get the city/location name from coordinates using reverse geocoding
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)) { placemarks, error in
            if let placemark = placemarks?.first {
                // Use city name, or locality, or area if available
                destination = placemark.locality ?? placemark.administrativeArea ?? "Current Location"
                destinationCoordinate = userLoc
            } else {
                // Fallback if geocoding fails
                destination = "Current Location"
                destinationCoordinate = userLoc
            }
        }
    }
}

// FIXED: Proper ViewModel with nonisolated delegate methods
@MainActor
class LocationManagerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // FIXED: Mark delegate methods as nonisolated
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.userLocation = location.coordinate
            manager.stopUpdatingLocation()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
