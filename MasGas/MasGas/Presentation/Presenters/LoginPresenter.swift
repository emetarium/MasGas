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
    let fetchSelectedTownUseCase: FetchSelectedTownUseCase?
    let emailLoginUseCase: EmailLoginUseCase?
    let googleLoginUseCase: GoogleLoginUseCase?
    
    init(_ view: LoginViewController) {
        self.view = view
        self.fetchFuelsUseCase = FetchFuelsUseCase()
        self.fetchTownsUseCase = FetchTownsUseCase()
        self.fetchSelectedTownUseCase = FetchSelectedTownUseCase()
        self.emailLoginUseCase = EmailLoginUseCase()
        self.googleLoginUseCase = GoogleLoginUseCase()
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
        if let town = fetchSelectedTownUseCase?.execute() {
            self.view.navigateToTabBar()
        }
        else {
            self.view.navigateToTownSelection()
        }
    }
    
    func emailLogin(email: String, password: String) {
        emailLoginUseCase?.execute(email: email, password: password, completion: { authError in
            if let authError = authError {
                let description = authError.get()
                let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default, handler: nil)
                self.view.showAlert(title: NSLocalizedString("AUTHENTICATION_ERROR_TITLE", comment: ""), message: description, alternativeAction: nil, acceptAction: acceptAction)
            } else {
                self.checkTown()
            }
        })
    }
    
    func googleLogin() {
        googleLoginUseCase?.execute(completion: { authError in
            if let authError = authError {
                let description = authError.get()
                let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default, handler: nil)
                self.view.showAlert(title: NSLocalizedString("AUTHENTICATION_ERROR_TITLE", comment: ""), message: description, alternativeAction: nil, acceptAction: acceptAction)
            } else {
                self.checkTown()
            }
        })
    }
}
