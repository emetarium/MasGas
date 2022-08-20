//
//  FuelsPresenter.swift
//  MasGas
//
//  Created by María García Torres on 19/2/22.
//

import Foundation

class FuelsPresenter<FuelSelectionProtocol>: BasePresenter {
    let fetchFuelsUseCase: FetchFuelsUseCase?
    let fetchSelectedTownUseCase: FetchSelectedTownUseCase?
    let deleteAccountUseCase: DeleteAccountUseCase?
    let logoutUseCase: LogOutUseCase?
    let view: FuelsViewController
    
    init(_ view: FuelsViewController) {
        self.view = view
        self.fetchFuelsUseCase = FetchFuelsUseCase()
        self.fetchSelectedTownUseCase = FetchSelectedTownUseCase()
        self.deleteAccountUseCase = DeleteAccountUseCase()
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
    
    func deleteAccount() {
        deleteAccountUseCase?.execute(completion: { error in
            print(error?.localizedDescription)
        })
        logout()
    }
    
    func checkInternetConnection() {
        if !isInternetAvailable() {
            self.view.showNoConnectionAlert()
        }
    }
}
