//
//  OptionsViewModel.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import Foundation

class OptionsViewModel {
    
    func isUserLogged() -> Bool {
        if UserDefaults.standard.object(forKey: "User") != nil {
            return true
        }
        else {
            return false
        }
    }
}
