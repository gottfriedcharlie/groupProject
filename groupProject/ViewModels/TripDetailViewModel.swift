// TripDetailViewModel.swift
// groupProject
// Created by Clare Morriss

import Foundation
import CoreLocation

// Prologue: view model for trip detail which handles most  logic and live updates for each trip's data
@MainActor
final class TripDetailViewModel: ObservableObject {
    @Published var trip: Trip
    @Published var totalDistance: Double = 0      // var for trip total distance in miles

    // optional parent view model which is used for updating the trip list when this trip changes
    private let parentViewModel: TripListViewModel?

    // initializes the trip, parentViewModel, and computes total distance
    init(trip: Trip, parentViewModel: TripListViewModel? = nil) {   // = nil default means it's optional
        self.trip = trip
        self.parentViewModel = parentViewModel
        calculateTotalDistance()
    }

    // computed property that returns the places in the itinerary for the current trip
    var places: [ItineraryPlace] { trip.itinerary }

    // function to calculate the distance in miles between two map coordinates
    func distanceBetween(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: location1.latitude, longitude: location1.longitude)
        let loc2 = CLLocation(latitude: location2.latitude, longitude: location2.longitude)
        return loc1.distance(from: loc2) / 1609.344 // convert meters to miles
    }

    // function to calculate the total distance covered in the entire itinerary (from trip start to first place)
    func calculateTotalDistance() {
        var total: Double = 0

        // if a destination is set AND there are places, count the distance from trip destination to first place
        if let tripCoord = trip.destinationCoordinate, !trip.itinerary.isEmpty {
            let firstPlace = CLLocationCoordinate2D(     // takes the coordinate location of the first item in the itinerary array
                latitude: trip.itinerary[0].latitude,
                longitude: trip.itinerary[0].longitude
            )
            total += distanceBetween(location1: tripCoord, location2: firstPlace)   // calls the distanceBetween function from above
        }

        // sum the distance between each pair of consecutive places (repeats the calculations from above just iterates through all places within the itinerary)
        if trip.itinerary.count > 1 {
            for i in 0..<(trip.itinerary.count - 1) {
                let currentPlace = CLLocationCoordinate2D(
                    latitude: trip.itinerary[i].latitude,
                    longitude: trip.itinerary[i].longitude
                )
                let nextPlace = CLLocationCoordinate2D(
                    latitude: trip.itinerary[i + 1].latitude,
                    longitude: trip.itinerary[i + 1].longitude
                )
                total += distanceBetween(location1: currentPlace, location2: nextPlace)
            }
        }
        self.totalDistance = total // Publish the computed distance
    }

    // calculates the distance in miles to the next place in the itinerary (or nil if last place on the trip)
    func distanceToNext(from index: Int) -> Double? {
        guard index < trip.itinerary.count - 1 else { return nil }  // if the condition after guard fails, the function returns nil & if the condition succeeds, the function continues to execute

        let currentPlace = CLLocationCoordinate2D(
            latitude: trip.itinerary[index].latitude,
            longitude: trip.itinerary[index].longitude
        )
        let nextPlace = CLLocationCoordinate2D(
            latitude: trip.itinerary[index + 1].latitude,
            longitude: trip.itinerary[index + 1].longitude
        )
        return distanceBetween(location1: currentPlace, location2: nextPlace)
    }

    // returns a formatted string for the total distance
    var totalDistanceString: String {
        // adapts the totalDistance function to a string for display purposes
        String(format: "%.1f miles", totalDistance)
    }

    // function to a new place to the trip's itinerary, update the total distance, and save the new altered trip
    func addPlace(_ place: ItineraryPlace) {
        var updatedTrip = trip
        updatedTrip.itinerary.append(place)
        trip = updatedTrip
        calculateTotalDistance()
        saveTrip()
    }

    // function which removes a place from the itinerary by ID, updates the total distance, and then saves the trip
    func deletePlace(_ place: ItineraryPlace) {
        trip.itinerary.removeAll { $0.id == place.id }
        calculateTotalDistance()
        saveTrip()
    }

    // function to remove places at specific offsets (which is for swipe-to-delete in UI), updates the total distance, and saves
    func removePlaces(at offsets: IndexSet) {
        trip.itinerary.remove(atOffsets: offsets)
        calculateTotalDistance()
        saveTrip()
    }

    // function which moves places in the itinerary (for drag/drop reorder in the UI), updates the total distance, and saves
    func movePlaces(from source: IndexSet, to destination: Int) {
        trip.itinerary.move(fromOffsets: source, toOffset: destination)
        calculateTotalDistance()
        saveTrip()
    }

    // function which saves the trip by updating it in the parent view model
    private func saveTrip() {
        parentViewModel?.updateTrip(trip)
    }
}
