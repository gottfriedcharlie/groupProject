//
//  Place.swift
//  groupProject
//

import Foundation
import CoreLocation

struct Place: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: PlaceCategory
    var latitude: Double
    var longitude: Double
    var notes: String
    var tripId: UUID
    
    init(id: UUID = UUID(),
         name: String,
         category: PlaceCategory,
         latitude: Double,
         longitude: Double,
         notes: String = "",
         tripId: UUID) {
        self.id = id
        self.name = name
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        self.tripId = tripId
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum PlaceCategory: String, Codable, CaseIterable {
    case restaurant = "Restaurant"
    case hotel = "Hotel"
    case attraction = "Attraction"
    case museum = "Museum"
    case park = "Park"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .hotel: return "bed.double"
        case .attraction: return "star"
        case .museum: return "building.columns"
        case .park: return "tree"
        case .other: return "mappin"
        }
    }
}
