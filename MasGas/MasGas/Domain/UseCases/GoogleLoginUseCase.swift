//
//  GoogleLoginUseCase.swift
//  MasGas
//
//  Created by María García Torres on 24/3/22.
//

import Foundation

class GoogleLoginUseCase {
    func execute(completion: @escaping (AuthenticationError?) -> ()) {
        Repository.shared.googleSignIn(completion: { authError in
            completion(authError)
        }
    )}
}
