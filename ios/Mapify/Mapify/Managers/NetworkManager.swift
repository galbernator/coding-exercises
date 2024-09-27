//
//  NetworkManager.swift
//  Mapify
//
//  Created by Steve Galbraith on 9/26/24.
//

import Foundation

protocol Network {
    func send<T: Decodable>(_ request: URLRequest) async -> Result<T, NetworkError>
}

enum NetworkError: Error {
    case callFailed(Error)
    case decodingFailed
    case invalidResponse(Int)
    case nonHTTPResponseReceived
    case stubFailed(String)
}

final class NetworkManager: Network {
    static let shared = NetworkManager()

    private init() {}

    func send<T: Decodable>(_ request: URLRequest) async -> Result<T, NetworkError> {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else { return .failure(.nonHTTPResponseReceived) }

            // In an app that has multiple endpoints this might be too simplistic and would possibly need to handle different status codes
            guard httpResponse.statusCode == 200 else { return .failure(.invalidResponse(httpResponse.statusCode)) }

            guard let object = try? JSONDecoder().decode(T.self, from: data) else { return .failure(.decodingFailed) }

            return .success(object)

        } catch {
            return .failure(.callFailed(error))
        }
    }
}

extension URLRequest {
    static var locations: URLRequest {
        let urlString = "https://raw.githubusercontent.com/galbernator/coding-exercises/refs/heads/master/mobile/map-locations/locations.json"
        return URLRequest(url: URL(string: urlString)!)
    }
}


final class NetworkStub: Network {
    func send<T: Decodable>(_ request: URLRequest) async -> Result<T, NetworkError> {
        guard request == .locations else { return .failure(.stubFailed("Invalid request for network stub")) }

        guard let url = Bundle.main.url(forResource: "locations", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return .failure(.stubFailed("Failed to load stub data"))
        }

        guard let object = try? JSONDecoder().decode(T.self, from: data) else {
            return .failure(.stubFailed("Failed to decode stub data"))
        }

        return .success(object)
    }
}
