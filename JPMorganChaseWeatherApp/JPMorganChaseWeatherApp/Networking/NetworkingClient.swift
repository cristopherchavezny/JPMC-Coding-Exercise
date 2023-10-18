//
//  NetworkingClient.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/11/23.
//

import Combine
import Foundation

class NetworkingClient {
    class func request(route: APIRoute) -> AnyPublisher<Data, NetworkingClientError> {
        var components = URLComponents()
        components.scheme = route.scheme
        components.host = route.host
        components.path = route.path
        components.queryItems = route.parameters
        
        guard let url = components.url
        else { return Fail(error: NetworkingClientError(kind: .invalidRequest("Invalid URL"))).eraseToAnyPublisher() }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = route.method
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap {
                guard let response = $0.response as? HTTPURLResponse
                else { throw NetworkingClientError(kind: .transportError) }

                /// There would be further processing of status codes to truly determine if a successful response was received
                switch response.statusCode {
                case 200:
                    return $0.data
                default:
                    throw NetworkingClientError(kind: .transportError, statusCode: response.statusCode)
                }
            }
            .mapError {
                return $0 as? NetworkingClientError ?? NetworkingClientError(kind: .unknown($0.localizedDescription))
            }
            .eraseToAnyPublisher()
    }
}
