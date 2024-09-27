//
//  MapView.swift
//  Mapify
//
//  Created by Steve Galbraith on 9/26/24.
//

import MapKit
import SwiftUI

struct MapView: View {
    let coordinator: MapCoordinator
    @Bindable var viewModel: MapViewModel

    @State private var cameraPosition: MapCameraPosition = .sanFransisco
    @State private var isShowingFilterList = false
    @State private var locations = [Location]()

    var body: some View {
        ZStack {
            // Map on the lowest z-index
            Map(position: $cameraPosition) {
                ForEach(locations) { location in
                    Annotation(location.name, coordinate: location.coordinate, accessoryAnchor: .center) {
                        annotationImage(for: location.type)
                            .onTapGesture {
                                coordinator.send(.locationTapped(location))
                            }
                    }

                }
            }

            VStack(alignment: .leading) {
                ZStack {
                    Button(
                        action: { coordinator.send(.filterButtonTapped) },
                        label: {
                            Image(systemName: isShowingFilterList ? "xmark" : "line.3.horizontal.decrease.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: filterImageSize, height: filterImageSize, alignment: .leading)
                                .padding(filterImagePadding)
                                .animation(.none, value: isShowingFilterList)
                                .foregroundStyle(isShowingFilterList ? .gray : .background)
                                .background(isShowingFilterList ? .background : .gray)
                                .clipShape(.circle)
                                .overlay {
                                    Circle().stroke(.gray)
                                }
                                .shadow(radius: 4)

                        }
                    )

                    if !viewModel.selectedFilters.isEmpty {
                        Text("\(viewModel.selectedFilters.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(6)
                            .foregroundStyle(.white)
                            .background(.teal)
                            .clipShape(.circle)
                            .overlay {
                                Circle().stroke(.gray)
                            }
                            .offset(x: 20, y: -20)

                    }
                }
                .padding()

                if isShowingFilterList {
                    ForEach(Array(LocationType.allCases.enumerated()), id: \.offset) { index, type in
                        FilterRow(for: type, at: index, isSelected: viewModel.selectedFilters.contains(type))
                            .onTapGesture {
                                coordinator.send(.filterTapped(type))
                            }
                    }
                    .padding(.leading)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: viewModel.visibleLocations) { _, newLocations in
            withAnimation(.easeInOut(duration: 0.8)) {
                cameraPosition = .sanFransisco
                locations = newLocations
            }
        }
        .onChange(of: viewModel.isShowingFilters) {  _, newValue in
            withAnimation {
                isShowingFilterList = newValue
            }
        }
        .onChange(of: viewModel.selectedLocation) { _, newLocation in
            withAnimation(.easeInOut(duration: 0.8)) {
                if let location = newLocation {
                    cameraPosition = .forLocation(location)
                } else {
                    // This was not animating correctly when we were setting to `.automatic`. ¯\_(ツ)_/¯
                    // Ideally if we were not sure that all locations would be within the set bounds we would use that instead.
                    cameraPosition = .sanFransisco
                }
            }
        }
        .sheet(item: $viewModel.selectedLocation) { location in
            dismissibleCard(for: location)
                .presentationDetents([.height(160)])
                .background(.clear)
        }
    }

    private var filterImageSize: CGFloat {
        isShowingFilterList ? 24 : 54
    }

    private var filterImagePadding: CGFloat {
        isShowingFilterList ? 15 : 0
    }

    private func annotationImage(for type: LocationType) -> some View {
        Image(systemName: type.iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18)
            .foregroundStyle(.white)
            .padding(8)
            .background(type.color)
            .clipShape(.circle)
    }

    private func dismissibleCard(for location: Location) -> some View {
        VStack {
            HStack {
                Spacer()

                Button(
                    action: { coordinator.send(.locationDetailsDismissTapped) },
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray.opacity(0.55))
                            .padding(5)

                    }
                )
                .padding([.top, .trailing], 8)
            }

            LocationDetailView(for: location)
        }
    }
}

#Preview {
    let viewModel = MapViewModel(network: NetworkStub())
    let coordinator = MapCoordinator(viewModel: viewModel)

    coordinator.start()
}

extension MapCameraPosition {
    static var sanFransisco: MapCameraPosition {
        .camera(.init(centerCoordinate: .sanFrancisco, distance: 5000))
    }

    static func forLocation(_ location: Location) -> MapCameraPosition {
        .camera(.init(centerCoordinate: location.coordinate, distance: 250, pitch: 60))
    }
}

extension Location {
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}

extension LocationType {
    var color: Color {
        switch self {
        case .bar: return .red
        case .cafe: return .blue
        case .landmark: return .gray
        case .museum: return .yellow
        case .park: return .green
        case .restaurant: return .orange
        }
    }
}
