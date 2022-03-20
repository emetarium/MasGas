//
//  SearchFuelUseCase.swift
//  MasGas
//
//  Created by María García Torres on 2/3/22.
//

import Foundation

class SearchFuelUseCase {
    var fuelsRepository = FuelsListRepository()
    
    func execute(fuelIdentifier: String, completion: @escaping ([ListaEESSPrecio]?) -> Void) {
        fuelsRepository.searchFuels(fuelIdentifier: fuelIdentifier) { listaPrecios in
            if let listaPrecios = listaPrecios {
                completion(listaPrecios)
            }
            completion(nil)
        }
    }
}
