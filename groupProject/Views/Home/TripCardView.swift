//
//  TripCardView.swift
//  groupProject
//
//   .
//

import SwiftUI

struct TripCardView: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trip.destination)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if trip.isUpcoming {
                    Text("Upcoming")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
            
            Text(trip.formattedDateRange)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("\(trip.durationInDays) days", systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("$\(trip.budget, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
}
