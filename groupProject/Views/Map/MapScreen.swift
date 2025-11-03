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
    @State private var trips: [Trip] = []
    @State private var selectedTripForSearch: Trip?
    
    let manager = CLLocationManager()
    let dataManager = DataManager.shared
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                UserAnnotation()
                Marker("Holycross", coordinate: holycross)
                Marker("Kimball", coordinate: kimball)
                Marker("Hogan", coordinate: hogan)
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
                        Image(systemName: "plus")
                    }
                    .tint(.blue)
                }
            }
        }
        .sheet(isPresented: $showingSearch) {
            MapSearchView(
                viewModel: searchViewModel,
                onAddPlace: { result, category in
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
                        
                        print("✅ Place added: \(result.name)")
                    } else {
                        print("❌ No trip found to add place to")
                    }
                }
            )
        }
    }
}

#Preview {
    NavigationView { MapScreen() }
}
