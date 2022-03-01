//
//  HomePresenter.swift
//  MasGas
//
//  Created by María García Torres on 19/2/22.
//

import Foundation

class HomePresenter<FuelSelectionProtocol> {
    let fetchFuelsUseCase: FetchFuelsUseCase?
    let view: HomeViewController
    
    init(_ view: HomeViewController) {
        self.view = view
        self.fetchFuelsUseCase = FetchFuelsUseCase()
    }
    
    func logout() {
        AuthenticationLayer.shared.signOut()
        self.view.navigateToLogin()
    }
}
