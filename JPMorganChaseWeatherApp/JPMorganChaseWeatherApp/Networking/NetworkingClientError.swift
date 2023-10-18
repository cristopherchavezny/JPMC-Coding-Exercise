//
//  NetworkingClientError.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/12/23.
//

import Foundation

struct NetworkingClientError: Error {
    enum ErrorKind {
        case invalidRequest(String)
        case transportError
        case unknown(String)
        case parsingError(String)
    }

    let kind: ErrorKind
    var statusCode: Int?
}
