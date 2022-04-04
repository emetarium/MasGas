//
//  EmailSignUpUseCase.swift
//  MasGas
//
//  Created by María García Torres on 24/3/22.
//

import Foundation

class EmailSignUpUseCase {
    func execute(email: String, password: String, completion: @escaping (AuthenticationError?) -> ()) {
        Repository.shared.emailSignUp(email: email, password: password) { authError in
            completion(authError)
        }
    }
}
