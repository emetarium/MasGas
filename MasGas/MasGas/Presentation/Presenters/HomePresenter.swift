//
//  HomePresenter.swift
//  MasGas
//
//  Created by María García Torres on 19/2/22.
//

import Foundation

class HomePresenter<FuelSelectionProtocol> {
    let fetchFuelsUseCase: FetchFuelsUseCase?
    let fetchSelectedTownUseCase: FetchSelectedTownUseCase?
    let logoutUseCase: LogOutUseCase?
    let view: HomeViewController
    
    init(_ view: HomeViewController) {
        self.view = view
        self.fetchFuelsUseCase = FetchFuelsUseCase()
        self.fetchSelectedTownUseCase = FetchSelectedTownUseCase()
        self.logoutUseCase = LogOutUseCase()
    }
    
    func fetchSelectedTown() {
        self.view.showLoadingIndicator()
        if let town = self.fetchSelectedTownUseCase?.execute() {
            self.view.updateTown(town: town)
        }
        self.view.hideLoadingIndicator()
    }
    
    func fetchFuels() {
        self.view.showLoadingIndicator()
        fetchFuelsUseCase?.execute(completion: { fuels in
            self.view.updateFuels(fuels: fuels)
            self.view.hideLoadingIndicator()
        })
    }
    
    func logout() {
        logoutUseCase?.execute()
        self.view.navigateToLogin()
    }
}
