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

class AuthenticationLayer {
    static let shared = AuthenticationLayer()
    let userSession = UserDefaults.standard
    
    private init() {}
    
    func emailSignIn(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            guard let user = user else { return }
            self.userSession.set(user.user.email, forKey: "Email")
        }
    }
    
    func emailSignUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let authResult = authResult else { return }
            self.userSession.set(authResult.user.email, forKey: "Email")
        }
    }
    
    func googleSignIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateGoogleUser(for: user, with: error)
            }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
            let configuration = GIDConfiguration(clientID: clientID)
        
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
                authenticateGoogleUser(for: user, with: error)
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            userSession.removeObject(forKey: "Email")
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func authenticateGoogleUser(for user: GIDGoogleUser?, with error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
      
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
      
        Auth.auth().signIn(with: credential) { authData, error in
            guard let authData = authData else { return }
            self.userSession.set(authData.user.email, forKey: "Email")
        }
    }
}
