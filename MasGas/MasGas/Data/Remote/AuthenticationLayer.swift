//
//  AuthenticationLayer.swift
//  MasGas
//
//  Created by María García Torres on 27/1/22.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import CryptoKit

enum AuthenticationError: Error {
    case invalidPassword(description: String)
    case emailAlreadyInUse(description: String)
    case invalidEmail(description: String)
    case wrongPassword(description: String)
    case userNotFound(description: String)
    case unknown(description: String)
    
    init(rawValue: Int) {
        switch rawValue {
            case 17007:
                self = .emailAlreadyInUse(description: NSLocalizedString("USED_EMAIL_ERROR", comment: ""))
            case 17008:
                self = .invalidEmail(description: NSLocalizedString("INVALID_EMAIL_ERROR", comment: ""))
            case 17009:
                self = .wrongPassword(description: NSLocalizedString("WRONG_PASSWORD_ERROR", comment: ""))
            case 17011:
                self = .userNotFound(description: NSLocalizedString("USER_NOT_FOUND_ERROR", comment: ""))
            case 17026:
                self = .invalidPassword(description: NSLocalizedString("INVALID_PASSWORD_ERROR", comment: ""))
            default:
                self = .unknown(description: NSLocalizedString("UNKNOWN_ERROR", comment: ""))
        }
    }
    
    func get() -> String {
        switch self {
            case .emailAlreadyInUse(let description):
                return description
            case .invalidEmail(let description):
                return description
            case .wrongPassword(let description):
                return description
            case .userNotFound(let description):
                return description
            case .invalidPassword(let description):
                return description
            default:
                return ""
        }
    }
}

class AuthenticationLayer {
    static let shared = AuthenticationLayer()
    
    private init() {}
    
    func emailSignIn(email: String, password: String, completion: @escaping ((Result<User, AuthenticationError>)) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let authError = error {
                completion(.failure(AuthenticationError(rawValue: authError._code)))
                return
            }
            else if let user = user {
                completion(.success(user.user))
            }
        }
    }
    
    func emailSignUp(email: String, password: String, completion: @escaping ((Result<User, AuthenticationError>)) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let authError = error {
                completion(.failure(AuthenticationError(rawValue: authError._code)))
                return
            }
            else if let user = authResult {
                completion(.success(user.user))
            }
        }
    }
    
    func googleSignIn(completion: @escaping ((Result<User, AuthenticationError>)) -> ()) {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateGoogleUser(for: user, with: error) { result in
                    switch result {
                        case .success(let user):
                            completion(.success(user))
                        case .failure(let error):
                            completion(.failure(AuthenticationError(rawValue: error._code)))
                    }
                }
            }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
            let configuration = GIDConfiguration(clientID: clientID)
        
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
                authenticateGoogleUser(for: user, with: error) { result in
                    switch result {
                        case .success(let user):
                            completion(.success(user))
                        case .failure(let error):
                            completion(.failure(AuthenticationError(rawValue: error._code)))
                    }
                }
            }
        }
    }
    
    func signOut() {
        if let providerId = Auth.auth().currentUser?.providerData.first?.providerID {
            if providerId == "apple.com" {
                // Clear saved user ID
                UserDefaults.standard.set(nil, forKey: "appleAuthorizedUserIdKey")
            } else if providerId == "google.com" {
                GIDSignIn.sharedInstance.signOut()
            }
        }
        
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func authenticateGoogleUser(for user: GIDGoogleUser?, with error: Error?, completion: @escaping ((Result<User, AuthenticationError>)) -> ()) {
        if let authError = error {
            completion(.failure(AuthenticationError(rawValue: authError._code)))
            return
        }
        
        guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
      
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
      
        Auth.auth().signIn(with: credential) { authData, error in
            if let error = error {
                completion(.failure(AuthenticationError(rawValue: error._code)))
                return
            }
            else if let user = authData {
                completion(.success(user.user))
            }
        }
    }
}
