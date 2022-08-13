//
//  FavoriteGasStationsPresenter.swift
//  MasGas
//
//  Created by María García Torres on 15/3/22.
//

import Foundation

class FavoriteGasStationsPresenter<FavoriteGasStationsProtocol>: BasePresenter {
    let view: FavoriteGasStationsViewController
    let favoriteGasStationsUseCase: GetFavoriteGasStationsUseCase?
    let removeFavoriteUseCase: RemoveFavoriteUseCase?
    let getLocationUseCase: GetLocationUseCase?
    
    init(_ view: FavoriteGasStationsViewController) {
        self.view = view
        self.favoriteGasStationsUseCase = GetFavoriteGasStationsUseCase()
        self.removeFavoriteUseCase = RemoveFavoriteUseCase()
        self.getLocationUseCase = GetLocationUseCase()
    }
    
    func setUpMap() {
        self.getLocationUseCase?.execute(completion: { location in
            if let location = location {
                self.view.setUpMap(location: location)
            }
        })
    }
    
    func getFavorites() {
        self.view.showLoadingIndicator()
        self.favoriteGasStationsUseCase?.execute(completion: { favoritesList in
            self.view.hideLoadingIndicator()
            if let favoritesList = favoritesList {
                self.view.updateFavoritesList(favoriteGasStations: favoritesList)
            }
        })
    }
    
    func removeFavorite(gasStation: Gasolinera) {
        removeFavoriteUseCase?.execute(gasStation: gasStation)
    }
    
    func checkInternetConnection() {
        if !isInternetAvailable() {
            self.view.showNoConnectionAlert()
        }
    }
}
