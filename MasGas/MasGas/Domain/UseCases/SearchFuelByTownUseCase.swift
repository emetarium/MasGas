//
//  SearchFuelByTownUseCase.swift
//  MasGas
//
//  Created by María García Torres on 26/9/24.
//

class SearchFuelByTownUseCase {
    func execute(townIdentifier: String, fuelIdentifier: String, completion: @escaping ([ListaEESSPrecio]?) -> Void) {
        Repository.shared.searchFuelInTown(townIdentifier: townIdentifier, fuelIdentifier: fuelIdentifier) { listaPrecios in
            completion(listaPrecios)
        }
    }
}
