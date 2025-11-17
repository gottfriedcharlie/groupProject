//
//  ItineraryBuilderView.swift
//  groupProject
//  Created by Charlie Gottfried
//The planning workspace. Map on top showing the trip destination and numbered stops in order. Search bar below to find and add new places. Collapsible sidebar on the left displays the full ordered list—grab and drag to rearrange the route.
import SwiftUI
import MapKit

struct ItineraryBuilderView: View {
    let trip: Trip
    @EnvironmentObject var itineraryViewModel: ItineraryViewModel
    @EnvironmentObject var tripListViewModel: TripListViewModel
    @StateObject private var searchViewModel = MapSearchViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var cameraPosition: MapCameraPosition
    @State private var selectedPin: GooglePlacesResult?
    @State private var showDetailSheet = false
    @State private var showItinerary = false  // sidebar toggle
    
    init(trip: Trip) {
        self.trip = trip
        // start map at trip destination or holy cross if no coords
        let initialCoord = trip.destinationCoordinate ?? CLLocationCoordinate2D(latitude: 42.259, longitude: -71.808)
        let fallbackRegion = MKCoordinateRegion(
            center: initialCoord,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        _cameraPosition = State(initialValue: .region(fallbackRegion))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // TOP: Map takes 2/3 of screen height
                ZStack(alignment: .topTrailing) {
                    Map(position: $cameraPosition) {
                        UserAnnotation()
                        
                        // Trip destination marker in green
                        if let coord = trip.destinationCoordinate {
                            Marker("📍 \(trip.destination)", coordinate: coord)
                                .tint(.green)
                        }
                        
                        // Itinerary places with numbers - helps visualize the route
                        ForEach(Array(itineraryViewModel.currentOrderedPlaces.enumerated()), id: \.element.id) { index, place in
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
                                }
                            }
                        }
                        
                        // Search result markers - orange and tappable
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
                    
                    // Control buttons floating on map
                    VStack(spacing: 12) {
                        Button(action: { showItinerary.toggle() }) {
                            Image(systemName: "list.dash")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.blue.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }
                    .padding(16)
                }
                
                // BOTTOM: Search section takes 1/3 of screen
                // this layout is based on the xu paper about mobile trip planning interfaces
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search places...", text: $searchText)
                            .textInputAutocapitalization(.none)
                            .font(.callout)
                        
                        //clear button
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    
                    // Search results list
                    if searchViewModel.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Searching...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else if !searchViewModel.searchResults.isEmpty {
                        List(searchViewModel.searchResults) { result in
                            Button(action: { selectedPin = result; showDetailSheet = true }) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Text(result.address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    
                                    //compact rating display
                                    if let rating = result.rating {
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                                .font(.caption2)
                                                .foregroundColor(.orange)
                                            Text(String(format: "%.1f", rating))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    } else if !searchText.isEmpty {
                        VStack {
                            Text("No results found")
                                .foregroundColor(.secondary)
                                .font(.callout)
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                )
            }
            
            // LEFT SIDEBAR: Collapsible Itinerary panel
            // ai helped with the transition animation here
            if showItinerary {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Itinerary")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { showItinerary = false }) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        //empty state
                        if itineraryViewModel.currentOrderedPlaces.isEmpty {
                            Text("Add places to start")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.vertical)
                        } else {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(Array(itineraryViewModel.currentOrderedPlaces.enumerated()), id: \.element.id) { index, place in
                                        HStack(spacing: 8) {
                                            // number badge
                                            Text("\(index + 1)")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .frame(width: 20, height: 20)
                                                .background(Color.blue)
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(place.name)
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .lineLimit(1)
                                                    .foregroundColor(.white)
                                                
                                                if let rating = place.rating {
                                                    HStack(spacing: 2) {
                                                        Image(systemName: "star.fill")
                                                            .font(.caption2)
                                                            .foregroundColor(.orange)
                                                        Text(String(format: "%.1f", rating))
                                                            .font(.caption2)
                                                            .foregroundColor(.white.opacity(0.8))
                                                    }
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            //delete button for each place
                                            Button(action: {
                                                itineraryViewModel.removePlace(place)
                                            }) {
                                                Image(systemName: "xmark")
                                                    .font(.caption)
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding(8)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .frame(maxWidth: 280)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.4))
                    )
                    .padding(12)
                    .transition(.move(edge: .leading))
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("Build Itinerary: \(trip.destination)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveItinerary()
                }
                .disabled(itineraryViewModel.currentOrderedPlaces.isEmpty)
            }
        }
        .onAppear {
            // Loading existing itinerary if there is one
            if !trip.itinerary.isEmpty {
                itineraryViewModel.currentOrderedPlaces = trip.itinerary
                itineraryViewModel.itineraryPlaces = trip.itinerary
            }
            itineraryViewModel.setSelectedTrip(trip)
            //update search center to trip destination for location-aware search
            searchViewModel.updateSearchCenter(to: trip.destinationCoordinate ?? CLLocationCoordinate2D(latitude: 42.259, longitude: -71.808))
        }
        .onChange(of: searchText) { oldValue, newValue in
            // trigger search after 2 characters
            if newValue.count >= 2 {
                searchViewModel.searchNearby(query: newValue)
            }
        }
        .sheet(item: $selectedPin) { result in
            ItineraryPlaceDetailSheet(
                place: result,
                userLocation: searchViewModel.currentSearchCenter,
                onAdd: {
                    itineraryViewModel.addPlace(result)
                    selectedPin = nil
                    searchText = ""  //clear search after adding
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
    
    private func saveItinerary() {
        // Create updated trip with new itinerary
        var updatedTrip = trip
        updatedTrip.itinerary = itineraryViewModel.currentOrderedPlaces
        
        // Update the trip in the list view model
        tripListViewModel.updateTrip(updatedTrip)
        
        // Clear the itinerary builder for next use
        itineraryViewModel.clearItinerary()
        
        // Go back to trip detail
        dismiss()
    }
    
    // MARK: - Detail Sheet for places in builder
    struct ItineraryPlaceDetailSheet: View {
        let place: GooglePlacesResult
        let userLocation: CLLocationCoordinate2D?
        let onAdd: () -> Void
        
        @Environment(\.dismiss) var dismiss
        @State private var isAdded = false
        
        //calculate distance from current search center
        private var distanceAway: Double? {
            guard let userLocation = userLocation else { return nil }
            let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            let placeLoc = CLLocation(latitude: place.latitude, longitude: place.longitude)
            return userLoc.distance(from: placeLoc)
        }
        
        var body: some View {
            NavigationView {
                VStack(spacing: 16) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(place.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.red)
                                Text(place.address)
                                    .font(.body)
                            }
                            
                            Divider()
                            
                            //rating section
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
                            
                            // show distance from search center
                            if let meters = distanceAway {
                                Text(String(format: "Distance: %.1f km away", meters/1000))
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                    }
                    
                    Button(action: {
                        onAdd()
                        isAdded = true
                        //auto dismiss after adding
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                            Text(isAdded ? "Added!" : "Add to Itinerary")
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
    
}
