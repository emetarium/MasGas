//
//  LogOutUseCase.swift
//  MasGas
//
//  Created by María García Torres on 24/3/22.
//

import Foundation

class LogOutUseCase {
    
    init() {}
    
    func execute() {
        Repository.shared.signOut()
    }
}
