//
//  Defaults.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/19/23.
//

import Foundation

class Defaults {
    private let defaults = UserDefaults.standard
  
    private let savedCityKey = "savedCityKey"
  
    var savedCoordinates: Coordinates? {
        set {
            defaults.setValue(try? PropertyListEncoder().encode(newValue), forKey: savedCityKey)
        }
        get {
            guard let data = defaults.object(forKey: savedCityKey) as? Data else { return nil }
            return try? PropertyListDecoder().decode(Coordinates.self, from: data)
        }
    }
}
