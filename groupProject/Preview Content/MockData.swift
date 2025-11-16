import Foundation

struct MockData {
    static let sampleTrip1 = Trip(
        name: "Tokyo Adventure",
        destination: "Tokyo, Japan",
        startDate: Date().addingTimeInterval(86400 * 30),
        endDate: Date().addingTimeInterval(86400 * 37),
        description: "Explore the vibrant streets of Tokyo, visit temples, and enjoy amazing food!",
        itinerary: []
    )

    static let sampleTrip2 = Trip(
        name: "Paris Escape",
        destination: "Paris, France",
        startDate: Date().addingTimeInterval(-86400 * 60),
        endDate: Date().addingTimeInterval(-86400 * 53),
        description: "Romantic getaway to the City of Light",
        itinerary: []
    )
    
    static let sampleTrips = [sampleTrip1, sampleTrip2]
    
    /*static let samplePlace1 = ItineraryPlace(
        id: UUID().uuidString,
        name: "Senso-ji Temple",
        address: "2 Chome-3-1 Asakusa, Taito City, Tokyo 111-0032, Japan",
        latitude: 35.7148,
        longitude: 139.7967,
        category: PlaceCategory.attraction,
        phoneNumber: nil,
        rating: 4.6,
        userRatingsTotal: 41848
    )

    static let samplePlace2 = ItineraryPlace(
        id: UUID().uuidString,
        name: "Sukiyabashi Jiro",
        address: "Tsukamoto Sogyo Building B1F, 2 Chome-15-4 Ginza, Chuo City, Tokyo 104-0061, Japan",
        latitude: 35.6712,
        longitude: 139.7634,
        category: PlaceCategory.restaurant,
        phoneNumber: nil,
        rating: 4.4,
        userRatingsTotal: 2382
    )


    
    static let samplePlaces = [samplePlace1, samplePlace2] */
}
