//
//  LoginPresenter.swift
//  MasGas
//
//  Created by María García Torres on 15/2/22.
//

import Foundation
import UIKit

class LoginPresenter<LoginProtocol> {
    
    let view: LoginViewController
    let fetchFuelsUseCase: FetchFuelsUseCase?
    let fetchTownsUseCase: FetchTownsUseCase?
    
    init(_ view: LoginViewController) {
        self.view = view
        self.fetchFuelsUseCase = FetchFuelsUseCase()
        self.fetchTownsUseCase = FetchTownsUseCase()
    }
    
    func isUserLogged() -> Bool {
        if UserDefaults.standard.object(forKey: "User") != nil {
            return true
        }
        else {
            return false
        }
    }
    
    func checkLogin() {
        if isUserLogged() {
            checkTown()
        }
    }
    
    func checkTown() {
        if UserDefaults.standard.object(forKey: "Town") != nil {
            self.view.navigateToHome()
        }
        else {
            self.view.navigateToTownSelection()
        }
    }
    
    func emailLogin(email: String, password: String) {
        AuthenticationLayer.shared.emailSignIn(email: email, password: password) { result in
            switch result {
                case .success(let user):
                    UserDefaults.standard.set(user.email, forKey: "User")
                    self.checkTown()
                case .failure(let error):
                    let description = error.get()
                    let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default, handler: nil)
                    self.view.showAlert(title: "Error", message: description, alternativeAction: nil, acceptAction: acceptAction)
            }
        }
    }
    
    func googleLogin() {
        AuthenticationLayer.shared.googleSignIn { result in
            switch result {
                case .success(let user):
                    UserDefaults.standard.set(user.email, forKey: "User")
                    self.checkTown()
                case .failure(let error):
                    let description = error.get()
                    let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default, handler: nil)
                    self.view.showAlert(title: NSLocalizedString("AUTHENTICATION_ERROR_TITLE", comment: ""), message: description, alternativeAction: nil, acceptAction: acceptAction)
            }
        }
    }
    
    func fetchFuels() {
        fetchFuelsUseCase?.execute(completion: { carburantes in
            self.view.getFuels(fuels: carburantes)
        })
    }
    
    func fetchTowns() {
        fetchTownsUseCase?.execute(completion: { municipios in
            self.view.getTowns(towns: municipios)
        })
    }
    
    func fetchSelectedTown() {
        if let data = UserDefaults.standard.data(forKey: "Town") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let town = try decoder.decode(Municipio.self, from: data)
                self.view.getSelectedTown(town: town)
            } catch {}
        }
    }
}
