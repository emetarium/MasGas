//
//  GasStationLocationViewModel.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import UIKit
import CoreLocation

protocol GasStationLocationViewModelDelegate {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showError(title: String, description: String)
    func updateLocation(location: CLLocation)
}

class GasStationLocationViewModel {
    
    var delegate: GasStationLocationViewModelDelegate?
    
    func isUserLogged() -> Bool {
        if UserDefaults.standard.object(forKey: "User") != nil {
            return true
        }
        else {
            return false
        }
    }
    
    func getLocation() {
        self.delegate?.showLoadingIndicator()
        if IsLocationEnabledUseCase().execute() {
            GetLocationUseCase().execute(completion: { location in
                self.delegate?.hideLoadingIndicator()
                guard let location else {
                    self.delegate?.showError(title: "", description: NSLocalizedString("NO_LOCATION_ERROR_MESSAGE", comment: ""))
                    return
                }
                self.delegate?.updateLocation(location: location)
            })
        } else {
            self.delegate?.hideLoadingIndicator()
            self.delegate?.showError(title: NSLocalizedString("NO_ROUTE_ERROR_TITLE", comment: ""), description: NSLocalizedString("NO_LOCATION_PERMISSION_MESSAGE", comment: ""))
        }
    }
    
    func saveFavorite(gasStation: Gasolinera) {
        SaveFavoriteGasStationUseCase().execute(gasStation: gasStation)
    }
    
    func removeFavorite(gasStation: Gasolinera) {
        RemoveFavoriteUseCase().execute(gasStation: gasStation)
    }
}
