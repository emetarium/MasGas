//
//  LocationLayer.swift
//  MasGas
//
//  Created by María García Torres on 3/3/22.
//

import Foundation
import CoreLocation

class LocationLayer: NSObject {
    static let shared = LocationLayer()
    private let locationManager = CLLocationManager()
    var location: CLLocation?

    override private init() {
        super.init()
        locationManager.delegate = self
    }

    func getCurrentLocation(completion: @escaping (CLLocation?) -> ()) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        completion(location)
    }

    func getDistanceBetweenLocations(userLocation: CLLocation, gasStationLocation: CLLocation) -> Double? {
        let distanceInMeters = userLocation.distance(from: gasStationLocation)
        let distanceInKm = distanceInMeters/1000
        return distanceInKm
    }
}

extension LocationLayer: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        self.location = userLocation
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
}
