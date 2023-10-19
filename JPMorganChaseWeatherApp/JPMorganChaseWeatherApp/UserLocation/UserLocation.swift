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

    let userLocationSubject = PassthroughSubject<Coordinates, UserLocationError>()

    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        
        super.init()
        
        locationManager.delegate = self
    }
    
    func getCoordinates() {
        DispatchQueue.main.async {
            self.locationManager.requestLocation()            
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            // Show message to user to enable location in settings
            userLocationSubject.send(completion: .failure(UserLocationError(kind: .denied)))
        case .restricted:
            userLocationSubject.send(completion: .failure(UserLocationError(kind: .restricted)))
        @unknown default:
            // Log analytics and show message
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            sendCoordinates(using: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle failure to get a user’s location like analytics and messaging
        userLocationSubject.send(
            completion: .failure(UserLocationError(kind: .error(error.localizedDescription)))
        )
    }
    
    private func sendCoordinates(using location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        userLocationSubject.send(Coordinates(latitude: latitude,
                                             longitude: longitude))
    }
}
