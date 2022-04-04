//
//  TownSelectionPresenter.swift
//  MasGas
//
//  Created by María García Torres on 22/2/22.
//

import Foundation

class TownSelectionPresenter<TownSelectionProtocol> {
    let view: TownSelectionViewController
    let fetchTownsUseCase: FetchTownsUseCase?
    
    init(_ view: TownSelectionViewController) {
        self.view = view
        self.fetchTownsUseCase = FetchTownsUseCase()
    }
    
    func fetchTowns() {
        self.view.showLoadingIndicator()
        self.fetchTownsUseCase?.execute(completion: { towns in
            self.view.hideLoadingIndicator()
            self.view.updateTowns(towns: towns)
        })
    }
    
    func saveTown(town: Municipio) {
        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(town)

            UserDefaults.standard.set(data, forKey: "Town")
        } catch { }
        self.view.navigateToTabBar(selectedTown: town)
    }
}
