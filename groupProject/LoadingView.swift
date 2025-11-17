//
//  LoadingView.swift
//  groupProject
//
// 
//

import SwiftUI

// LoadingView - Simple loading spinner with text
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5, anchor: .center)
            
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    LoadingView()
}
