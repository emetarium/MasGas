//
//  GasStationLocationPresenter.swift
//  MasGas
//
//  Created by María García Torres on 15/3/22.
//

import Foundation

class GasStationLocationPresenter {
    let view: GasStationLocationViewController
    let saveFavoriteUseCase: SaveFavoriteGasStationUseCase?
    let removeFavoriteUseCase: RemoveFavoriteUseCase?
    
    init(_ view: GasStationLocationViewController) {
        self.view = view
        self.saveFavoriteUseCase = SaveFavoriteGasStationUseCase()
        self.removeFavoriteUseCase = RemoveFavoriteUseCase()
    }
    
    func saveFavorite(gasStation: Gasolinera) {
        saveFavoriteUseCase?.execute(gasStation: gasStation)
    }
    
    func removeFavorite(gasStation: Gasolinera) {
        removeFavoriteUseCase?.execute(gasStation: gasStation)
    }
}
