import SwiftUI

struct PlaceRowView: View {
    let place: ItineraryPlace

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
