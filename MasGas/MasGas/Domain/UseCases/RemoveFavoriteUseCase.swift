//
//  RemoveFavoriteUseCase.swift
//  MasGas
//
//  Created by María García Torres on 17/3/22.
//

import Foundation

class RemoveFavoriteUseCase {
    var favoritesRepository = FavoritesListRepository()
    
    func execute(gasStation: Gasolinera) {
        favoritesRepository.removeFavorite(gasStation: gasStation)
    }
}
