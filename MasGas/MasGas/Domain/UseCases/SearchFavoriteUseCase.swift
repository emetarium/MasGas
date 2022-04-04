//
//  SearchFavoriteUseCase.swift
//  MasGas
//
//  Created by María García Torres on 14/3/22.
//

import Foundation

class SearchFavoriteUseCase {
    
    func execute(gasStationID: String, completion: @escaping (Bool) -> ()) {
        Repository.shared.isFavorite(gasStationID: gasStationID) { result in
            completion(result)
        }
    }
}
