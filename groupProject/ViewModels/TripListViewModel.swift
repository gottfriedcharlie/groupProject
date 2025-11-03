//
//  TripListViewModel.swift
//  groupProject
//
//
import Foundation
import Combine

@MainActor
final class TripListViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var searchText = ""
    @Published var filterOption: TripFilter = .all
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTrips()
        setupSearchObserver()
    }
    
    var filteredTrips: [Trip] {
        var result = trips
        
        if !searchText.isEmpty {
            result = result.filter { trip in
                trip.destination.localizedCaseInsensitiveContains(searchText) ||
                trip.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch filterOption {
        case .upcoming:
            result = result.filter { $0.isUpcoming }
        case .past:
            result = result.filter { !$0.isUpcoming }
        case .all:
            break
        }
        
        return result.sorted { $0.startDate > $1.startDate }
    }
    
    func loadTrips() {
        trips = dataManager.loadTrips()
    }
    
    func addTrip(_ trip: Trip) {
        trips.append(trip)
        dataManager.saveTrips(trips)
    }
    
    func deleteTrip(_ trip: Trip) {
        trips.removeAll { $0.id == trip.id }
        dataManager.saveTrips(trips)
    }
    
    func updateTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
            dataManager.saveTrips(trips)
        }
    }
    
    private func setupSearchObserver() {
        $searchText
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}

enum TripFilter {
    case all, upcoming, past
}
