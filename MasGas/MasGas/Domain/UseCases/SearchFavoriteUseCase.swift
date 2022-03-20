//
//  SearchFavoriteUseCase.swift
//  MasGas
//
//  Created by María García Torres on 14/3/22.
//

import Foundation

class SearchFavoriteUseCase {
    var favoritesRepository = FavoritesListRepository()
    
    func execute(gasStationID: String, completion: @escaping (Bool) -> ()) {
        favoritesRepository.isFavorite(gasStationID: gasStationID) { result in
            completion(result)
        }
    }
}
