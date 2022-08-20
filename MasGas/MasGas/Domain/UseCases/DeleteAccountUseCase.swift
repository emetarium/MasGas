//
//  DeleteAccountUseCase.swift
//  MasGas
//
//  Created by María García Torres on 20/8/22.
//

import Foundation

class DeleteAccountUseCase {
    func execute(completion: @escaping (AuthenticationError?) -> ()) {
        Repository.shared.deleteAccount(completion: { authError in
            completion(authError)
        }
    )}
}
