//
//  APIRoute.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/11/23.
//

import Foundation

enum APIRoute {
    case getWeather(lat: String, lon: String, units: String?)
    case getGeocoding(String, String?)
    case getWeatherIcons(String)
    
    var scheme: String {
        switch self {
        case .getWeather, .getGeocoding, .getWeatherIcons:
            return "https"
        }
    }
    
    var host: String {
        switch self {
        case .getWeather, .getGeocoding:
            return "api.openweathermap.org"
        case .getWeatherIcons:
            return "openweathermap.org"
        }
    }
    
    var path: String {
        switch self {
        case .getWeather:
            return "/data/2.5/weather"
        case .getGeocoding:
            return "/geo/1.0/direct"
        case .getWeatherIcons(let code):
            return "/img/wn/\(code)@2x.png"
        }
    }
    
    var parameters: [URLQueryItem] {
        /// This would not be hard coded within the app like this
        /// It is not a secure way to store keys/ tokens
        var params: [URLQueryItem] = []
        
        switch self {
        case .getWeather(let lat, let lon, let units):
            params.append(contentsOf: [URLQueryItem(name: "lat", value: lat),
                                       URLQueryItem(name: "lon", value: lon),
                                       URLQueryItem(name: "units", value: units ?? "imperial")])
        case .getGeocoding(let q, let limit):
            params.append(contentsOf: [URLQueryItem(name: "q", value: q),
                                       URLQueryItem(name: "limit", value: limit ?? "5")])
        case .getWeatherIcons:
            return []
        }

        params.append(URLQueryItem(name: "appid", value: ""))
        return params
    }
    
    var method: String {
        switch self {
        case .getWeather, .getGeocoding, .getWeatherIcons:
            return "GET"
        }
    }
}
