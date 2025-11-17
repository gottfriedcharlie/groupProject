import SwiftUI
import MapKit

struct MapScreen: View {
    
    private static let fallbackRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.23943764672886, longitude: -71.80796616765598),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .region(MapScreen.fallbackRegion))
    @State private var showingSearch = false
    @State private var showingTripSelector = false
    @StateObject private var searchViewModel = MapSearchViewModel()
    @EnvironmentObject var itineraryViewModel: ItineraryViewModel
    @EnvironmentObject var placesViewModel: PlacesViewModel
    @EnvironmentObject var tripListViewModel: TripListViewModel
    @State private var trips: [Trip] = []
    @State private var selectedPin: GooglePlacesResult?
    @State private var showDetailSheet = false
    @State private var selectedTrip: Trip?
    
    let manager = CLLocationManager()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                // Selected Trip Destination
                if let trip = selectedTrip, let coord = trip.destinationCoordinate {
                    Marker("📍 \(trip.destination)", coordinate: coord)
                        .tint(.green)
                }
                
                // Selected Trip Itinerary Places with numbers
                if let trip = selectedTrip {
                    ForEach(Array(trip.itinerary.enumerated()), id: \.element.id) { index, place in
                        Annotation("\(index + 1). \(place.name)", coordinate: place.coordinate) {
                            VStack(spacing: 4) {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                
                                Image(systemName: "triangle.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                
                // Search result markers - tappable
                ForEach(searchViewModel.searchResults) { result in
                    Annotation(result.name, coordinate: result.coordinate) {
                        Button(action: {
                            selectedPin = result
                            showDetailSheet = true
                        }) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
            }
            .onAppear {
                manager.requestWhenInUseAuthorization()
                tripListViewModel.loadTrips()
            }
            
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .tint(.blue)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingTripSelector = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "airplane.circle.fill")
                            if let trip = selectedTrip {
                                Text(trip.name)
                                    .font(.subheadline)
                            } else {
                                Text("Select Trip")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .tint(.blue)
                }
            }
            
            // Trip info card (top-left overlay)
            if let trip = selectedTrip {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trip.name)
                                .font(.headline)
                                .fontWeight(.bold)
                            Text(trip.destination)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(trip.itinerary.count) places")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                selectedTrip = nil
                                cameraPosition = .userLocation(fallback: .region(MapScreen.fallbackRegion))
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title3)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 5)
                )
                .padding(.top, 60)
                .padding(.horizontal, 16)
            }
        }
        .sheet(isPresented: $showingSearch) {
            MapSearchView(
                viewModel: searchViewModel,
                onAddPlace: { result, category in
                    let itineraryPlace = ItineraryPlace(from: result)
                    
                    // If a trip is selected, add directly to that trip (DON'T save to places)
                    if let trip = selectedTrip {
                        var updatedTrip = trip
                        if !updatedTrip.itinerary.contains(where: { $0.id == itineraryPlace.id }) {
                            updatedTrip.itinerary.append(itineraryPlace)
                            tripListViewModel.updateTrip(updatedTrip)
                            selectedTrip = updatedTrip
                            print("✅ Place added to trip '\(trip.name)': \(result.name) (NOT saved to places)")
                        }
                    } else {
                        // No trip selected, add to places only
                        placesViewModel.addPlace(itineraryPlace)
                        itineraryViewModel.addPlace(result)
                        print("✅ Place saved to places tab: \(result.name)")
                    }
                }
            )
        }
        .sheet(isPresented: $showingTripSelector) {
            TripSelectorSheet(
                trips: tripListViewModel.trips,
                selectedTrip: $selectedTrip,
                onTripSelected: { trip in
                    selectedTrip = trip
                    
                    if let coord = trip.destinationCoordinate {
                        withAnimation {
                            cameraPosition = .region(MKCoordinateRegion(
                                center: coord,
                                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                            ))
                        }
                    }
                    
                    if let coord = trip.destinationCoordinate {
                        searchViewModel.updateSearchCenter(to: coord)
                    }
                    
                    showingTripSelector = false
                }
            )
        }
        .sheet(isPresented: $showDetailSheet) {
            if let pin = selectedPin {
                MapPinDetailSheet(
                    place: pin,
                    placesViewModel: placesViewModel,
                    itineraryViewModel: itineraryViewModel,
                    selectedTrip: selectedTrip,
                    tripListViewModel: tripListViewModel,
                    onClose: { showDetailSheet = false },
                    onTripUpdated: { updatedTrip in
                        selectedTrip = updatedTrip
                    }
                )
            }
        }
        .onChange(of: tripListViewModel.trips) { oldValue, newValue in
            if let currentTrip = selectedTrip,
               let updatedTrip = newValue.first(where: { $0.id == currentTrip.id }) {
                selectedTrip = updatedTrip
            }
        }
    }
}

// MARK: - Trip Selector Sheet
struct TripSelectorSheet: View {
    let trips: [Trip]
    @Binding var selectedTrip: Trip?
    let onTripSelected: (Trip) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if trips.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Trips Yet")
                            .font(.headline)
                        Text("Create a trip from the Trips tab")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(trips) { trip in
                        Button(action: {
                            onTripSelected(trip)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(trip.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(trip.destination)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    HStack {
                                        Text(trip.formattedDateRange)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        if trip.isUpcoming {
                                            Text("Upcoming")
                                                .font(.caption2)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Color.blue.opacity(0.2))
                                                .foregroundColor(.blue)
                                                .cornerRadius(4)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                if selectedTrip?.id == trip.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Select Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Updated Map Pin Detail Sheet
struct MapPinDetailSheet: View {
    let place: GooglePlacesResult
    let placesViewModel: PlacesViewModel
    let itineraryViewModel: ItineraryViewModel
    let selectedTrip: Trip?
    let tripListViewModel: TripListViewModel
    let onClose: () -> Void
    let onTripUpdated: (Trip) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var isAdded = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Name
                        Text(place.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Address
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.red)
                            Text(place.address)
                                .font(.body)
                        }
                        
                        Divider()
                        
                        // Rating
                        if let rating = place.rating {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rating")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                HStack(spacing: 8) {
                                    HStack(spacing: 2) {
                                        ForEach(0..<5, id: \.self) { index in
                                            Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    Text(String(format: "%.1f", rating))
                                        .fontWeight(.semibold)
                                    if let total = place.userRatingsTotal {
                                        Text("(\(total) reviews)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Divider()
                        }
                        
                        // Phone
                        if let phone = place.phoneNumber, !phone.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Phone")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Link(phone, destination: URL(string: "tel:\(phone)")!)
                                    .foregroundColor(.blue)
                            }
                            
                            Divider()
                        }
                        
                        // Types
                        if !place.placeTypes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Type")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                HStack(spacing: 8) {
                                    ForEach(place.placeTypes.prefix(3), id: \.self) { type in
                                        Text(type.capitalized)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(8)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        
                        // Show which trip it will be added to
                        if let trip = selectedTrip {
                            Divider()
                            HStack {
                                Image(systemName: "airplane")
                                    .foregroundColor(.blue)
                                Text("Adding to: \(trip.name)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                
                // Add Button
                Button(action: {
                    let itineraryPlace = ItineraryPlace(from: place)
                    
                    if let trip = selectedTrip {
                        // Add to trip (don't save to places)
                        var updatedTrip = trip
                        if !updatedTrip.itinerary.contains(where: { $0.id == itineraryPlace.id }) {
                            updatedTrip.itinerary.append(itineraryPlace)
                            tripListViewModel.updateTrip(updatedTrip)
                            onTripUpdated(updatedTrip)
                            print("✅ Place added to trip '\(trip.name)': \(place.name) (NOT saved to places)")
                        }
                    } else {
                        // No trip selected, save to places
                        placesViewModel.addPlace(itineraryPlace)
                        itineraryViewModel.addPlace(place)
                        print("✅ Place saved to places: \(place.name)")
                    }
                    
                    isAdded = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }) {
                    HStack {
                        Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                        if let trip = selectedTrip {
                            Text(isAdded ? "Added to \(trip.name)!" : "Add to \(trip.name)")
                        } else {
                            Text(isAdded ? "Added!" : "Add to Places")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAdded ? Color.green : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isAdded)
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView { MapScreen() }
        .environmentObject(ItineraryViewModel())
        .environmentObject(PlacesViewModel())
        .environmentObject(TripListViewModel())
}
