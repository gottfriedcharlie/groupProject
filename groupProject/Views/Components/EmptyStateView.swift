import SwiftUI
// reusable view for displaying an informative message and icon when a list or screen has no data to show ("empty state")

struct EmptyStateView: View {
    let icon: String        // visual displayed
    let title: String       // initial title
    let message: String     // descriptive message
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding() // Adds extra space around the whole component
    }
}
