//
//  PlaceRowView.swift
//  groupProject
//
//   .
//

import SwiftUI

struct PlaceRowView: View {
    let place: ItineraryPlace

    var body: some View {
        HStack {
            // You may need to update 'category.icon' depending on your ItineraryPlace model.
            Image(systemName: place.placeTypes.first.flatMap { PlaceCategory(rawValue: $0)?.icon } ?? "mappin")
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.body)
            }
        }
        .padding(.vertical, 4)
    }
}
