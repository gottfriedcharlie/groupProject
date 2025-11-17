// Colin O'Connor
// PlacesRowView.swift
// groupProject
//
// Prologue: A view that displays a single place as a node in a list format. It includes important data in a compact and easy-to-read way. This component is used in PlacesView, TripDetailView, and in Search Results.
import SwiftUI
struct PlaceRowView: View {
    let place: ItineraryPlace // The places data that is going to be displayed
    // UI
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: place.category.icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.body)
                Text(place.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(place.category.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                if let rating = place.rating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", rating))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
    // Retuns a symbol for whichever category the place fall into
    func iconForCategory(_ category: String?) -> String {
        switch category?.lowercased() ?? "other" {
            case "restaurant": return "fork.knife"
            case "hotel": return "bed.double"
            case "attraction": return "star"
            case "museum": return "building.columns"
            case "park": return "tree"
            default: return "mappin"
        }
    }
}
