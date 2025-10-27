//
//  MapScreen.swift
//  groupProject
//
//  Created by Charlie Gottfried on 10/26/25.
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
    
    
    let manager = CLLocationManager()
    
    var body: some View {
        
        Map(position: $cameraPosition){
            UserAnnotation()
            Marker("Holycross", coordinate: holycross)
            Marker("Kimball", coordinate: kimball)
            Marker("Hogan", coordinate: hogan)
        }
        
        .mapControls{
            MapUserLocationButton()
        }
        .onAppear {
            manager.requestWhenInUseAuthorization()
        }
        
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                } label: {
                    Image(systemName: "plus")
                }
                .tint(.blue)
            }
            
            
        }
    }
}

#Preview {
    NavigationView { MapScreen() }
}
