//
//  MapCoordinator.swift
//  Mapify
//
//  Created by Steve Galbraith on 9/26/24.
//

import SwiftUI

final class MapCoordinator {
    private let viewModel: MapViewModel

    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }

    enum Event {
        case clearFilters
        case filterButtonTapped
        case filterTapped(LocationType)
        case locationDetailsDismissTapped
        case locationTapped(Location)
    }

    func send(_ event: Event) {
        switch event {
        case .clearFilters:
            viewModel.clearFilters()
        case .filterButtonTapped:
            viewModel.isShowingFilters.toggle()
        case let .filterTapped(type):
            viewModel.handleFilterTap(for: type)
        case .locationDetailsDismissTapped:
            viewModel.selectedLocation = nil
        case let .locationTapped(location):
            viewModel.selectedLocation = location
        }
    }
}

extension MapCoordinator {
    func start() -> some View {
        MapView(coordinator: self, viewModel: viewModel)
    }
}
