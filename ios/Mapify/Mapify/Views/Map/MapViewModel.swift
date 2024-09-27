//
//  MapViewModel.swift
//  Mapify
//
//  Created by Steve Galbraith on 9/26/24.
//

import Foundation
import Observation

@Observable
final class MapViewModel {
    let network: Network

    private(set) var selectedFilters = [LocationType]()
    private var _locationsDictionary = [LocationType: [Location]]()
    var selectedLocation: Location?
    var isShowingFilters = false

    var visibleLocations: [Location] {
        if selectedFilters.isEmpty {
            return _locationsDictionary.values.flatMap { $0 }
        } else {
            return selectedFilters.reduce([]) { $0 + (_locationsDictionary[$1] ?? []) }
        }
    }

    init(network: Network = NetworkManager.shared) {
        self.network = network

        fetchLocations()
    }

    private func fetchLocations() {
        Task {
            let result: Result<[Location], NetworkError> = await network.send(.locations)

            switch result {
            case let .success(locations):
                let dictionary = createLocationsDictionary(from: locations)
                await MainActor.run {
                    _locationsDictionary = dictionary
                }
            case .failure:
                print("Something went wrong")
            }
        }
    }

    private func createLocationsDictionary(from locations: [Location]) -> [LocationType: [Location]] {
        var dictionary = [LocationType: [Location]]()

        locations.forEach { location in
            dictionary[location.type, default: []].append(location)
        }

        return dictionary
    }

    func handleFilterTap(for type: LocationType) {
        if let selectedIndex = selectedFilters.firstIndex(of: type) {
            selectedFilters.remove(at: selectedIndex)
        } else {
            selectedFilters.append(type)
        }
    }

    func clearFilters() {
        selectedFilters.removeAll()
    }
}
