//
//  UserLocationError.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/19/23.
//

import Foundation

struct UserLocationError: Error {
    enum ErrorKind {
        case notDetermined
        case denied
        case restricted
        case error(String)
    }
    
    let kind: ErrorKind
}
