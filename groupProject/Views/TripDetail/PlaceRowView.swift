//
//  PlaceRowView.swift
//  groupProject
//
//  Created by Charlie Gottfried on 10/24/25.
//

import SwiftUI

struct PlaceRowView: View {
    let place: Place
    
    var body: some View {
        HStack {
            Image(systemName: place.category.icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.body)
                
                if !place.notes.isEmpty {
                    Text(place.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
