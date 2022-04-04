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
    let signUpUseCase: EmailSignUpUseCase?
    
    init(_ view: SignUpViewController) {
        self.view = view
        self.signUpUseCase = EmailSignUpUseCase()
    }
    
    func signUp(email: String, password: String) {
        signUpUseCase?.execute(email: email, password: password, completion: { authError in
            if let authError = authError {
                let description = authError.get()
                let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default, handler: nil)
                self.view.showAlert(title: NSLocalizedString("SIGN_UP_ERROR_TITLE", comment: ""), message: description, alternativeAction: nil, acceptAction: acceptAction)
            } else {
                self.view.navigateToLogin()
            }
        })
    }
}
