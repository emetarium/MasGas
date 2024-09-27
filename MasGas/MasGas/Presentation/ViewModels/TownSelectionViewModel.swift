//
//  TownSelectionViewModel.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import Foundation

protocol TownSelectionViewModelDelegate {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func updateTowns(towns: [Municipio])
    func navigateToTabBar(selectedTown: Municipio)
}

class TownSelectionViewModel {
    
    var delegate: TownSelectionViewModelDelegate?
    
    func fetchTowns() {
        self.delegate?.showLoadingIndicator()
        FetchTownsUseCase().execute(completion: { towns in
            self.delegate?.hideLoadingIndicator()
            self.delegate?.updateTowns(towns: towns)
        })
    }
    
    func saveTown(town: Municipio) {
        SaveTownUseCase(town: town).execute()
        self.delegate?.navigateToTabBar(selectedTown: town)
    }
}
