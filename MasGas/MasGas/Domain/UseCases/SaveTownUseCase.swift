//
//  SaveTownUseCase.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import Foundation

class SaveTownUseCase {
    
    var town: Municipio
    
    init(town: Municipio) {
        self.town = town
    }
    
    func execute() {
        Repository.shared.saveTown(town: town)
    }
}
