//
//  Location.swift
//  Mapify
//
//  Created by Steve Galbraith on 9/26/24.
//

import Foundation

enum LocationType: String, Decodable, CaseIterable {
    case bar
    case cafe
    case landmark
    case museum
    case park
    case restaurant

    var title: String {
        rawValue.capitalized
    }

    var filterTitle: String {
        title + "s"
    }

    var iconName: String {
        switch self {
        case .bar: return "wineglass"
        case .cafe: return "cup.and.saucer"
        case .landmark: return "binoculars"
        case .museum: return "building.columns"
        case .park: return "tree"
        case .restaurant: return "fork.knife"
        }
    }
}

struct Location: Decodable, Identifiable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let type: LocationType
    let name: String
    let description: String
    let estimatedRevenueInMillions: Double

    enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case attributes
    }

    init(
        id: Int,
        latitude: Double,
        longitude: Double,
        type: LocationType,
        name: String,
        description: String,
        estimatedRevenueInMillions: Double
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.type = type
        self.name = name
        self.description = description
        self.estimatedRevenueInMillions = estimatedRevenueInMillions
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        let attributes = try container.decode([Attribute].self, forKey: .attributes)
        // Create dictionary for faster lookup
        let attributeDictionary = Dictionary(uniqueKeysWithValues: attributes.map { ($0.type, $0.value) })

        // Force unwrapping is evil, but doing it here since I can see the JSON in its entirety
        // If there were doubts about what could come back I would have it throw a more descriptive error
        type = LocationType(rawValue: attributeDictionary["location_type"] as! String)!
        name = attributeDictionary["name"] as! String
        description = attributeDictionary["description"] as! String
        estimatedRevenueInMillions = attributeDictionary["estimated_revenue_millions"] as! Double
    }

    private struct Attribute: Decodable {
        let type: String
        let value: Any

        enum CodingKeys: String, CodingKey {
            case type
            case value
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            type = try container.decode(String.self, forKey: .type)

            // Since I can see the JSON I will only implement the two types that will be coming back.
            // Otherwise we would handle all of the different standard types (Bool, Int, etc...)
            if let stringValue = try? container.decode(String.self, forKey: .value) {
                value = stringValue
            } else if let doubleValue = try? container.decode(Double.self, forKey: .value) {
                value = doubleValue
            } else {
                let context: DecodingError.Context = .init(
                    codingPath: container.codingPath, 
                    debugDescription: "Attribute value was not a String or Double as expected. Please handle the new type."
                )
                throw DecodingError.dataCorrupted(context)
            }
        }
    }
}

extension Location: Equatable {
    public static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}

extension Location {
    static var examples: [Location] {
        [
            .barExample,
            .cafeExample,
            .landmarkExample,
            .museumExample,
            .parkExample,
            .restaurantExample
        ]
    }

    static var barExample: Location {
        Location(
            id: 0,
            latitude: 37.7743,
            longitude: -122.4195,
            type: .bar,
            name: "Golden Gate Bar",
            description: "Lively bar with craft beers.",
            estimatedRevenueInMillions: 100
        )
    }

    static var cafeExample: Location {
        Location(
            id: 0,
            latitude: 37.7744,
            longitude: -122.4196,
            type: .cafe,
            name: "Golden Gate Cafe",
            description: "A cafe serving delicious food and drinks.",
            estimatedRevenueInMillions: 10
        )
    }

    static var landmarkExample: Location {
        Location(
            id: 1,
            latitude: 37.7745,
            longitude: -122.4197,
            type: .landmark,
            name: "Golden Gate Bridge",
            description: "A landmark bridge spanning the Golden Gate.",
            estimatedRevenueInMillions: 100
        )
    }

    static var museumExample: Location {
        Location(
            id: 2,
            latitude: 37.7746,
            longitude: -122.4198,
            type: .museum,
            name: "Golden Gate Museum",
            description: "A museum dedicated to the history of the bay.",
            estimatedRevenueInMillions: 1
        )
    }

    static var parkExample: Location {
        Location(
            id: 36,
            latitude: 37.7747,
            longitude: -122.4199,
            type: .park,
            name: "Patricia's Green",
            description: "Community park with art installations.",
            estimatedRevenueInMillions: 7.4
        )
    }

    static var restaurantExample: Location {
        Location(
            id: 1,
            latitude: 37.7750,
            longitude: -122.4195,
            type: .restaurant,
            name: "Golden Gate Grill",
            description: "A popular eatery with views of the bay.",
            estimatedRevenueInMillions: 10.5
        )
    }
}
