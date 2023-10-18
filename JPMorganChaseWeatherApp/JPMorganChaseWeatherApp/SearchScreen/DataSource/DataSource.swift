//
//  DataSource.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/14/23.
//

import Combine
import Foundation
import CoreImage

class DataSource {
    init () {}
    
    func geocoding(query: String) ->AnyPublisher<[Geocode], NetworkingClientError> {
        fetchGeocoding(query: query)
    }
    
    private func fetchGeocoding(query: String) -> AnyPublisher<[Geocode], NetworkingClientError> {
        NetworkingClient.request(route: .getGeocoding(query, nil))
            .tryMap {
                do {
                    let responseObject = try JSONDecoder().decode([Geocode].self, from: $0)
                    return responseObject
                } catch (let error) {
                    throw NetworkingClientError(kind: .parsingError(error.localizedDescription))
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
