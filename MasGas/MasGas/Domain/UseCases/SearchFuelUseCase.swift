//
//  SearchFuelUseCase.swift
//  MasGas
//
//  Created by María García Torres on 2/3/22.
//

import Foundation

class SearchFuelUseCase {
    func execute(fuelIdentifier: String, completion: @escaping ([ListaEESSPrecio]?) -> Void) {
        Repository.shared.searchFuels(fuelIdentifier: fuelIdentifier) { listaPrecios in
            completion(listaPrecios)
        }
    }
}
