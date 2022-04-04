//
//  SaveFavoriteGasStationUseCase.swift
//  MasGas
//
//  Created by María García Torres on 14/3/22.
//

import Foundation

class SaveFavoriteGasStationUseCase {
    
    func execute(gasStation: Gasolinera) {
        Repository.shared.saveFavorite(gasStation: gasStation)
    }
}
