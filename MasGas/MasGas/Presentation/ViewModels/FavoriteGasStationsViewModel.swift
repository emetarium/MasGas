//
//  FavoriteGasStationsViewModel.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import Foundation
import CoreLocation

protocol FavoriteGasStationsViewModelDelegate {
    func setUpMap(location: CLLocation)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func updateFavoritesList(favoriteGasStations: [PreciosGasolinera])
}

class FavoriteGasStationsViewModel {
    
    var delegate: FavoriteGasStationsViewModelDelegate?
    
    func isUserLogged() -> Bool {
        if UserDefaults.standard.object(forKey: "User") != nil {
            return true
        }
        else {
            return false
        }
    }
    
    func setUpMap() {
        GetLocationUseCase().execute(completion: { location in
            if let location {
                self.delegate?.setUpMap(location: location)
            }
        })
    }
    
    func getFavorites() {
        self.delegate?.showLoadingIndicator()
        GetFavoriteGasStationsUseCase().execute(completion: { favoritesList in
            self.delegate?.hideLoadingIndicator()
            if let favoritesList {
                self.delegate?.updateFavoritesList(favoriteGasStations: favoritesList)
            }
        })
    }
    
    func removeFavorite(gasStation: Gasolinera) {
        RemoveFavoriteUseCase().execute(gasStation: gasStation)
    }
}
