//
//  Trip.swift
//  groupProject
//
//   .
//

import Foundation

struct Trip: Identifiable, Codable, Hashable {
    let id: UUID
    var destination: String
    var startDate: Date
    var endDate: Date
    var description: String
    var budget: Double
    var imageURL: String?
    
    init(id: UUID = UUID(),
         destination: String,
         startDate: Date,
         endDate: Date,
         description: String = "",
         budget: Double = 0) {
        self.id = id
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
        self.budget = budget
    }
    
    var durationInDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    var isUpcoming: Bool {
        startDate > Date()
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
