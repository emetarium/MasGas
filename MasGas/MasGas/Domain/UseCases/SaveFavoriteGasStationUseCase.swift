//
//  SaveFavoriteGasStationUseCase.swift
//  MasGas
//
//  Created by María García Torres on 14/3/22.
//

import Foundation

class SaveFavoriteGasStationUseCase {
    var favoritesRepository = FavoritesListRepository()
    
    func execute(gasStation: Gasolinera) {
        favoritesRepository.saveFavorite(gasStation: gasStation)
    }
}
