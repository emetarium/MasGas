//
//  FetchFuelsUseCase.swift
//  MasGas
//
//  Created by María García Torres on 17/2/22.
//

import Foundation

class FetchFuelsUseCase {
    var fuelsRepository =  FuelsListRepository()
    
    func execute(completion: @escaping ([Carburante]) -> Void) {
        var carburantesFiltrados: [Carburante] = []
        fuelsRepository.fetchFuels { carburantes in
            carburantes.forEach { carburante in
                if filteredFuels.contains(carburante.nombreProductoAbreviatura) {
                    carburantesFiltrados.append(carburante)
                }
            }
            completion(carburantesFiltrados)
        }
    }
}
