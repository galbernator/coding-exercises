//
//  FilterRow.swift
//  Mapify
//
//  Created by Steve Galbraith on 9/26/24.
//

import SwiftUI

struct FilterRow: View {
    let filter: LocationType
    let index: Int
    let isSelected: Bool

    @State private var startAnimating = false

    init(for filter: LocationType, at index: Int, isSelected: Bool) {
        self.filter = filter
        self.index = index
        self.isSelected = isSelected
    }

    var body: some View {
        HStack {
            Image(systemName: filter.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .padding(8)
                .foregroundStyle(.white)
                .background(filter.color)
                .clipShape(.circle)
                .overlay {
                    Circle().stroke(.white)
                }
                .offset(x: -4)

            Text(filter.filterTitle)
                .font(.headline)
                .foregroundStyle(isSelected ? .white : .primary.opacity(0.8))
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isSelected ? .teal : .background)
        .clipShape(.capsule)
        .overlay {
            Capsule().stroke(.gray)
        }
        .opacity(startAnimating ? 1.0 : 0.0)
        .offset(y: startAnimating ? 0 : -16)
        .animation(.linear(duration: 0.15).delay(Double(index) * 0.075), value: startAnimating)
        .onAppear {
            startAnimating = true
        }
    }
}

#Preview {
    VStack {
        FilterRow(for: .cafe, at: 0, isSelected: false)

        FilterRow(for: .restaurant, at: 1, isSelected: true)
    }
}
