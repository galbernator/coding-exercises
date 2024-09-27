//
//  MapifyApp.swift
//  Mapify
//
//  Created by Steve Galbraith on 9/26/24.
//

import SwiftUI

@main
struct MapifyApp: App {
    var body: some Scene {
        WindowGroup {
            let viewModel = MapViewModel()
            let coordinator = MapCoordinator(viewModel: viewModel)

            coordinator.start()
        }
    }
}
