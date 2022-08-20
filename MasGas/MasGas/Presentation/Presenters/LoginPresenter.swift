//
//  LoginPresenter.swift
//  MasGas
//
//  Created by María García Torres on 15/2/22.
//

import Foundation
import CryptoKit
import UIKit

class LoginPresenter<LoginProtocol> {
    
    let view: LoginViewController
    let fetchFuelsUseCase: FetchFuelsUseCase?
    let fetchTownsUseCase: FetchTownsUseCase?
    let fetchSelectedTownUseCase: FetchSelectedTownUseCase?
    let emailLoginUseCase: EmailLoginUseCase?
    let googleLoginUseCase: GoogleLoginUseCase?
    
    init(_ view: LoginViewController) {
        self.view = view
        self.fetchFuelsUseCase = FetchFuelsUseCase()
        self.fetchTownsUseCase = FetchTownsUseCase()
        self.fetchSelectedTownUseCase = FetchSelectedTownUseCase()
        self.emailLoginUseCase = EmailLoginUseCase()
        self.googleLoginUseCase = GoogleLoginUseCase()
    }
    
    func isUserLogged() -> Bool {
        if UserDefaults.standard.object(forKey: "User") != nil {
            return true
        }
        else {
            return false
        }
    }
    
    func checkLogin() {
        if isUserLogged() {
            checkTown()
        }
    }
    
    func checkTown() {
        if let town = fetchSelectedTownUseCase?.execute() {
            self.view.navigateToTabBar()
        }
        else {
            self.view.navigateToTownSelection()
        }
    }
    
    func emailLogin(email: String, password: String) {
        emailLoginUseCase?.execute(email: email, password: password, completion: { authError in
            if let authError = authError {
                let description = authError.get()
                let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default, handler: nil)
                self.view.showAlert(title: NSLocalizedString("AUTHENTICATION_ERROR_TITLE", comment: ""), message: description, alternativeAction: nil, acceptAction: acceptAction)
            } else {
                self.checkTown()
            }
        })
    }
    
    func googleLogin() {
        googleLoginUseCase?.execute(completion: { authError in
            if let authError = authError {
                let description = authError.get()
                let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default, handler: nil)
                self.view.showAlert(title: NSLocalizedString("AUTHENTICATION_ERROR_TITLE", comment: ""), message: description, alternativeAction: nil, acceptAction: acceptAction)
            } else {
                self.checkTown()
            }
        })
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
