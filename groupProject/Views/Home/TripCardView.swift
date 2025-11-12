import SwiftUI

// A single card or row view showing a trip summary in trip lists.
// Displays trip name as a bold title, destination as subtitle, and other summary info.
struct TripCardView: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main headline: Name (bold), destination (subheadline, secondary color)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    // Bold trip name (e.g. "Family Vacation")
                    Text(trip.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    // Lighter subtitle for location/destination (e.g. "Barcelona, Spain")
                    Text(trip.destination)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                // "Upcoming" badge for future trips
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
            // Date range for the trip in secondary caption styling
            Text(trip.formattedDateRange)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                // Duration label (calendar icon + number of days)
                Label("\(trip.durationInDays) days", systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                // Budget (right-aligned, green for emphasis)
                Text("$\(trip.budget, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8) // Padding for vertical whitespace
    }
}
