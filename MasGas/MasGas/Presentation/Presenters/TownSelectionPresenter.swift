//
//  TownSelectionPresenter.swift
//  MasGas
//
//  Created by María García Torres on 22/2/22.
//

import Foundation

class TownSelectionPresenter<TownSelectionProtocol> {
    let view: TownSelectionViewController
    
    init(_ view: TownSelectionViewController) {
        self.view = view
    }
    
    func saveTown(town: Municipio) {
        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(town)

            UserDefaults.standard.set(data, forKey: "Town")
        } catch { }
        self.view.navigateToHome(selectedTown: town)
    }
}
