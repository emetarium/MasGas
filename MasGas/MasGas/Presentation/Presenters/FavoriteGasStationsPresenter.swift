//
//  FavoriteGasStationsPresenter.swift
//  MasGas
//
//  Created by María García Torres on 15/3/22.
//

import Foundation

class FavoriteGasStationsPresenter<FavoriteGasStationsProtocol> {
    let view: FavoriteGasStationsViewController
    let favoriteGasStationsUseCase: GetFavoriteGasStationsUseCase?
    
    init(_ view: FavoriteGasStationsViewController) {
        self.view = view
        self.favoriteGasStationsUseCase = GetFavoriteGasStationsUseCase()
    }
    
    func getFavorites() {
        self.view.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.favoriteGasStationsUseCase?.execute(completion: { favoritesList in
                if let favoritesList = favoritesList {
                    self.view.updateFavoritesList(favoriteGasStations: favoritesList)
                    self.view.hideLoading()
                }
            })
        }
    }
}
