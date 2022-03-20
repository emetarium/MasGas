//
//  SignUpPresenter.swift
//  MasGas
//
//  Created by María García Torres on 15/2/22.
//

import Foundation
import UIKit

class SignUpPresenter<SignUpProtocol> {
    let view: SignUpViewController
    
    init(_ view: SignUpViewController) {
        self.view = view
    }
    
    func signUp(email: String, password: String) {
        AuthenticationLayer.shared.emailSignUp(email: email, password: password) { result in
            switch result {
                case .success(let user):
                    UserDefaults.standard.set(user.email, forKey: "User")
                    self.view.navigateToLogin()
                case .failure(let error):
                    let description = error.get()
                    let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default, handler: nil)
                    self.view.showAlert(title: "Error", message: description, alternativeAction: nil, acceptAction: acceptAction)
            }
        }
    }
}
