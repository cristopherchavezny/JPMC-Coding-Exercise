//
//  Forecast.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/18/23.
//

import Foundation

struct Forecast: Codable, Hashable {
    let weather: [Weather]
    let coordinates: Coordinates
    let temperature: Temperature
    let visibility: Int
    let sys: Sys
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case weather
        case coordinates = "coord"
        case temperature = "main"
        case visibility
        case sys
        case name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(weather)
        hasher.combine(coordinates)
        hasher.combine(temperature)
        hasher.combine(sys)
    }
}

struct Sys: Codable, Hashable {
    let type: Int?
    let id: Int?
    let country: String
    let sunrise: Int
    let sunset: Int
}

struct Temperature: Codable, Hashable {
    let temperature: Double
    let feelsLike: Double
    let temperatureMin: Double
    let temperatureMax: Double
    let pressure: Double
    let humidity: Double
    let seaLevel: Double?
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case temperatureMin = "temp_min"
        case temperatureMax = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        
        
    }
}

struct Weather: Codable, Hashable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
