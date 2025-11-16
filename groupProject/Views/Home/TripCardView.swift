import SwiftUI

// Visual summary of each Trip in the list: name, destination, date, etc.
struct TripCardView: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(trip.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(trip.destination)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
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
            }
        }
        .padding(.vertical, 8)
    }
}
