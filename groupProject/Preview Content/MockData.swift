//
//  MockData.swift
//  groupProject
//
//   .
//

import Foundation

struct MockData {
    static let sampleTrip1 = Trip(
        name: "Tokyo Adventure",                // <-- Add this line!
        destination: "Tokyo, Japan",
        startDate: Date().addingTimeInterval(86400 * 30),
        endDate: Date().addingTimeInterval(86400 * 37),
        description: "Explore the vibrant streets of Tokyo, visit temples, and enjoy amazing food!",
        budget: 3500
    )

    static let sampleTrip2 = Trip(
        name: "Paris Escape",                   // <-- Add this line!
        destination: "Paris, France",
        startDate: Date().addingTimeInterval(-86400 * 60),
        endDate: Date().addingTimeInterval(-86400 * 53),
        description: "Romantic getaway to the City of Light",
        budget: 4200
    )
    
    static let sampleTrips = [sampleTrip1, sampleTrip2]
    
    static let samplePlace1 = Place(
        name: "Senso-ji Temple",
        category: .attraction,
        latitude: 35.7148,
        longitude: 139.7967,
        notes: "Historic Buddhist temple in Asakusa",
        tripId: sampleTrip1.id
    )
    
    static let samplePlace2 = Place(
        name: "Sukiyabashi Jiro",
        category: .restaurant,
        latitude: 35.6712,
        longitude: 139.7634,
        notes: "Famous sushi restaurant",
        tripId: sampleTrip1.id
    )
    
    static let samplePlaces = [samplePlace1, samplePlace2]
}
