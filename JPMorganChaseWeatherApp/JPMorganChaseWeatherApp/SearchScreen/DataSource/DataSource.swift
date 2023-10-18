//
//  DataSource.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/14/23.
//

import Combine
import Foundation

class DataSource {
    init () {}
    
    func geocoding<T: Decodable>(type: T.Type, query: String) -> AnyPublisher<[T], NetworkingClientError> {
        fetch(route: .getGeocoding(query, nil))
    }
    
    func fetchWeather<T: Decodable>(type: T.Type, coordinates: Coordinates)  -> AnyPublisher<T, NetworkingClientError> {
        fetch(route: .getWeather(lat: "\(coordinates.latitude)",
                                 lon: "\(coordinates.longitude)",
                                 units: nil))
    }
    
    private func fetch<T: Decodable>(route: APIRoute) -> AnyPublisher<T, NetworkingClientError> {
        NetworkingClient.request(route: route)
            .tryMap {
                do {
                    let responseObject = try JSONDecoder().decode(T.self, from: $0)
                    return responseObject
                } catch (let error) {
                    if let decodingError = error as? DecodingError {
                        throw NetworkingClientError(kind: .parsingError(decodingError.localizedDescription))
                    }
                    throw NetworkingClientError(kind: .unknown(error.localizedDescription))
                }
            }
            .mapError {
                // We would log the error to our analytics
                // For now we will print the error
                return $0 as? NetworkingClientError ?? NetworkingClientError(kind: .unknown($0.localizedDescription))
            }
            .eraseToAnyPublisher()
    }
}
