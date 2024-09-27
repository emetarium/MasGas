//
//  SignUpViewModel.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import Foundation

protocol SignUpViewModelDelegate {
    func showError(title: String, message: String)
    func navigateToLogin()
}

class SignUpViewModel {
    
    var delegate: SignUpViewModelDelegate?
    
    func signUp(email: String, password: String) {
        EmailSignUpUseCase().execute(email: email, password: password, completion: { authError in
            if let authError = authError {
                self.delegate?.showError(title: NSLocalizedString("SIGN_UP_ERROR_TITLE", comment: ""), message: authError.get())
            } else {
                self.delegate?.navigateToLogin()
            }
        })
    }
}
