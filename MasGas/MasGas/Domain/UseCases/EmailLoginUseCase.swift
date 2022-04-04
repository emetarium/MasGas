//
//  EmailLoginUseCase.swift
//  MasGas
//
//  Created by María García Torres on 24/3/22.
//

import Foundation

class EmailLoginUseCase {
    func execute(email: String, password: String, completion: @escaping (AuthenticationError?) -> ()) {
        Repository.shared.emailSignIn(email: email, password: password) { authError in
            completion(authError)
        }
    }
}
