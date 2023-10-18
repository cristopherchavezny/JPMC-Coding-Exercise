//
//  UserLocation.swift
//  JPMorganChaseWeatherApp
//
//  Created by Cris C on 10/18/23.
//

import Combine
import Foundation
import CoreLocation

class UserLocation: NSObject, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager

    let userLocationSubject = PassthroughSubject<Coordinates, Error>()

    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        
        super.init()
        
        locationManager.delegate = self
    }
    
    func getCoordinates() {
        locationManager.requestLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            break
            // Show message to user to enable location in settings
        @unknown default:
            // Log analytics and show message
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            userLocationSubject.send(Coordinates(latitude: latitude,
                                                  longitude: longitude))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle failure to get a user’s location like analytics and messaging
        // For now prin error
        userLocationSubject.send(completion: .failure(error))
    }
}
