//
//  GetFavoriteGasStationsUseCase.swift
//  MasGas
//
//  Created by María García Torres on 14/3/22.
//

import Foundation

class GetFavoriteGasStationsUseCase {
    func execute(completion: @escaping ([PreciosGasolinera]?) -> ()) {
        Repository.shared.getFavoritesList { gasolineras in
            completion(gasolineras)
        }
    }
}
