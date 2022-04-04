//
//  GetFavoriteGasStationsUseCase.swift
//  MasGas
//
//  Created by María García Torres on 14/3/22.
//

import Foundation

class GetFavoriteGasStationsUseCase {
    func execute(completion: @escaping ([Gasolinera]?) -> ()) {
        Repository.shared.getFavoritesList { gasolineras in
            completion(gasolineras)
        }
    }
}
