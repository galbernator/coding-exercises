//
//  LocationDetailView.swift
//  Mapify
//
//  Created by Steve Galbraith on 9/26/24.
//

import SwiftUI

struct LocationDetailView: View {
    let location: Location

    init(for location: Location) {
        self.location = location
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text(location.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(location.type.color)
                    .frame(maxWidth: .infinity, alignment: .leading)


                Text("\(location.type.title) • Est. Revenue: \(String(format: "%.1f", location.estimatedRevenueInMillions)) M")
                    .font(.caption2)
                    .foregroundStyle(.primary.opacity(0.7))
            }

            HStack(alignment: .top, spacing: 16) {
                Image(systemName: location.type.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)

                Text(location.description)
                    .foregroundStyle(.primary.opacity(0.85))
            }
        }
        .padding(.horizontal)
        .offset(y: -12)
    }
}

#Preview {
    ScrollView {
        ForEach(Location.examples) { location in
            LocationDetailView(for: location)
        }
    }
}
