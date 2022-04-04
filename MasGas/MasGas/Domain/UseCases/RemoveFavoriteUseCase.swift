//
//  RemoveFavoriteUseCase.swift
//  MasGas
//
//  Created by María García Torres on 17/3/22.
//

import Foundation

class RemoveFavoriteUseCase {
    func execute(gasStation: Gasolinera) {
        Repository.shared.removeFavorite(gasStation: gasStation)
    }
}
