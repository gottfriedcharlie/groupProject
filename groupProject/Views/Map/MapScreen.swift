//
//  MapScreen.swift
//  groupProject
//

import SwiftUI
import MapKit

struct MapScreen: View {
    
    let holycross = CLLocationCoordinate2D(latitude: 42.23943764672886,  longitude: -71.80796616765598)
    let kimball = CLLocationCoordinate2D(latitude: 42.24039047196402, longitude:  -71.80806525911412)
    let hogan = CLLocationCoordinate2D(latitude: 42.23757318738827, longitude:  -71.8081546995765)
    
    private static let fallbackRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.23943764672886, longitude: -71.80796616765598),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .region(MapScreen.fallbackRegion))
    @State private var showingSearch = false
    @StateObject private var searchViewModel = MapSearchViewModel()
    @StateObject private var itineraryViewModel = ItineraryViewModel()
    @State private var trips: [Trip] = []
    @State private var selectedPin: GooglePlacesResult?
    @State private var showDetailSheet = false
    
    let manager = CLLocationManager()
    let dataManager = DataManager.shared
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                // Static markers
                Marker("Holycross", coordinate: holycross)
                Marker("Kimball", coordinate: kimball)
                Marker("Hogan", coordinate: hogan)
                
                // Search result markers - tappable
                ForEach(searchViewModel.searchResults) { result in
                    Annotation(result.name, coordinate: result.coordinate) {
                        Button(action: {
                            selectedPin = result
                            showDetailSheet = true
                        }) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
            }
            .onAppear {
                manager.requestWhenInUseAuthorization()
                trips = dataManager.loadTrips()
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
            }
        }
        .sheet(isPresented: $showingSearch) {
            MapSearchView(
                viewModel: searchViewModel,
                onAddPlace: { result, category in
                    // Add to itinerary
                    itineraryViewModel.addPlace(result)
                    
                    // Also save as Place to trip if desired
                    if let trip = trips.first(where: { $0.isUpcoming }) ?? trips.first {
                        let place = Place(
                            name: result.name,
                            category: category,
                            latitude: result.latitude,
                            longitude: result.longitude,
                            notes: result.phoneNumber ?? "",
                            tripId: trip.id
                        )
                        
                        var places = dataManager.loadPlaces(for: trip.id)
                        places.append(place)
                        dataManager.savePlaces(places)
                        
                        print("✅ Place added to itinerary: \(result.name)")
                    }
                }
            )
        }
        .sheet(isPresented: $showDetailSheet) {
            if let pin = selectedPin {
                MapPinDetailSheet(
                    place: pin,
                    itineraryViewModel: itineraryViewModel,
                    onClose: { showDetailSheet = false }
                )
            }
        }
    }
}

struct MapPinDetailSheet: View {
    let place: GooglePlacesResult
    let itineraryViewModel: ItineraryViewModel
    let onClose: () -> Void
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
                    }
                    .padding()
                }
                
                // Add Button
                Button(action: {
                    itineraryViewModel.addPlace(place)
                    isAdded = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }) {
                    HStack {
                        Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                        Text(isAdded ? "Added!" : "Add")
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
}
