//
//  FetchSelectedTownUseCase.swift
//  MasGas
//
//  Created by María García Torres on 30/3/22.
//

import Foundation

class FetchSelectedTownUseCase {
    func execute() -> Municipio? {
        return Repository.shared.fetchSelectedTown()
    }
}
