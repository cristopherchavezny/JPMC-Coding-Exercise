//
//  Coordinates.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/18/23.
//

import Foundation

struct Coordinates: Codable, Equatable, Hashable {
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
    case latitude = "lat"
    case longitude = "lon"
    }
}
