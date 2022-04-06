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
    var handleLocation: ((CLLocation?) -> ())?

    override private init() {
        super.init()
        locationManager.delegate = self
    }

    func startGettingLocation() {
        //handleLocation?(CLLocation(latitude: 37.876691, longitude: -4.791934))
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    func getDistanceBetweenLocations(userLocation: CLLocation, gasStationLocation: CLLocation, completion: (Double?) -> ()) {
        let distanceInMeters = userLocation.distance(from: gasStationLocation)
        let distanceInKm = distanceInMeters/1000
        completion(distanceInKm)
    }
}

extension LocationLayer: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        handleLocation?(self.location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
}
