//
//  CalculateDistanceBetweenLocationsUseCase.swift
//  MasGas
//
//  Created by María García Torres on 27/3/22.
//

import Foundation
import CoreLocation

class CalculateDistanceBetweenLocationsUseCase {
    func execute(userLocation: CLLocation, gasStation: CLLocation, completion: (Double) -> ()) {
        Repository.shared.calculateDistanceBetweenLocations(userLocation: userLocation, gasStationLocation: gasStation) { distance in
            completion(distance)
        }
    }
}
