//
//  RouteViewModel.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import Foundation

protocol RouteViewModelDelegate {
    func setFuels(fuels: [Carburante])
}

class RouteViewModel {
    
    var delegate: RouteViewModelDelegate?
    
    func getFuels() {
        let getFuelsUseCase = FetchFuelsUseCase()
        getFuelsUseCase.execute { fuels in
            self.delegate?.setFuels(fuels: fuels)
        }
    }
}
