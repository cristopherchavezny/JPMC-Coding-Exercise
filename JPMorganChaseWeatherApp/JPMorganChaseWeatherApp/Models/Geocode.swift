//
//  Geocode.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/14/23.
//

import Foundation

struct Geocode: Codable, Hashable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}
