//
//  GetFavoriteGasStationsUseCase.swift
//  MasGas
//
//  Created by María García Torres on 14/3/22.
//

import Foundation

class GetFavoriteGasStationsUseCase {
    var favoritesRepository = FavoritesListRepository()
    
    func execute(completion: @escaping ([Gasolinera]?) -> ()) {
        favoritesRepository.getFavoritesList { gasolineras in
            completion(gasolineras)
        }
    }
}
