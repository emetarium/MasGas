//
//  FetchTownsUseCase.swift
//  MasGas
//
//  Created by María García Torres on 22/2/22.
//

import Foundation

class FetchTownsUseCase {
    func execute(completion: @escaping ([Municipio]) -> Void) {
        Repository.shared.fetchTowns { municipios in
            completion(municipios)
        }
    }
}
