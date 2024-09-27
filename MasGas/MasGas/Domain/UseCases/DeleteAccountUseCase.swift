//
//  DeleteAccountUseCase.swift
//  MasGas
//
//  Created by María García Torres on 20/8/22.
//

import Foundation

protocol DeleteAccountUseCaseDelegate {
    func deletedAccount(error: AuthenticationError?)
}

class DeleteAccountUseCase {
    
    var delegate: DeleteAccountUseCaseDelegate
    
    init(delegate: DeleteAccountUseCaseDelegate) {
        self.delegate = delegate
    }
    
    func execute() {
        Repository.shared.deleteAccount(completion: { authError in
            self.delegate.deletedAccount(error: authError)
        })
    }
}
