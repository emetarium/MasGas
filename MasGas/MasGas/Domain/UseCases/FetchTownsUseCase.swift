//
//  FetchTownsUseCase.swift
//  MasGas
//
//  Created by María García Torres on 22/2/22.
//

import Foundation

class FetchTownsUseCase {
    var townsRepository = TownsListRepository()
    
    func execute(completion: @escaping ([Municipio]) -> Void) {
        townsRepository.fetchTowns { municipios in
            completion(municipios)
        }
    }
}
