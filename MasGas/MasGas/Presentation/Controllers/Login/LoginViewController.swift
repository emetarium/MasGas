//
//  LoginViewController.swift
//  MasGas
//
//  Created by María García Torres on 26/1/22.
//

import UIKit
import GoogleSignIn
import Firebase
import CryptoKit
import AuthenticationServices

protocol LoginProtocol {
    func navigateToTabBar()
    func navigateToTownSelection()
}

class LoginViewController: BaseViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var loginButton: CustomButton!
    @IBOutlet var separatorLine: UIView!
    @IBOutlet var googleSignInButton: CustomButton!
    @IBOutlet var appleSignInButton: CustomButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet var notNowButton: UIButton!
    
    //MARK: - Variables
    var viewModel = LoginViewModel()
    var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        setDelegates()
        setGestureHideKeyboard()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.checkLogin()
    }
    
    //MARK: - Functions
    func setUpUI() {
        emailTextField.backgroundColor = Colors.lightGray
        emailTextField.placeholder = NSLocalizedString("EMAIL_TEXT_FIELD_PLACEHOLDER", comment: "")
        
        passwordTextField.backgroundColor = Colors.lightGray
        passwordTextField.placeholder = NSLocalizedString("PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "")
        
        loginButton.titleText = NSLocalizedString("LOGIN_BUTTON", comment: "")
        loginButton.style = .filled
        
        separatorLine.backgroundColor = Colors.mediumLightGray
        
        googleSignInButton.titleText = NSLocalizedString("GOOGLE_LOGIN_BUTTON", comment: "")
        googleSignInButton.style = .bordered
        
        appleSignInButton.titleText = NSLocalizedString("APPLE_LOGIN_BUTTON", comment: "")
        appleSignInButton.style = .bordered
        
        signUpLabel.font = Fonts.defaultx16
        signUpLabel.text = NSLocalizedString("SIGN_UP_LABEL", comment: "")
        
        signUpButton.setTitle(NSLocalizedString("SIGN_UP_BUTTON", comment: ""), for: .normal)
        signUpButton.titleLabel?.font = Fonts.defaultx16
        signUpButton.tintColor = Colors.clear
        signUpButton.setTitleColor(Colors.green, for: .normal)
        
        notNowButton.tintColor = Colors.green
        notNowButton.setTitleColor(Colors.green, for: .normal)
        notNowButton.setTitle(NSLocalizedString("NOT_NOW_BUTTON", comment: ""), for: .normal)
        notNowButton.titleLabel?.font = Fonts.defaultx16
    }
    
    func setDelegates() {
        viewModel.delegate = self
    }
    
    func setGestureHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    //MARK: - IBActions
    @IBAction func loginButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        viewModel.emailLogin(email: email, password: password)
    }
    
    @IBAction func googleLoginButton(_ sender: Any) {
        viewModel.googleLogin()
    }
    
    @IBAction func appleLoginButton(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        // Generate nonce for validation after authentication successful
        self.currentNonce = viewModel.randomNonceString()
        // Set the SHA256 hashed nonce to ASAuthorizationAppleIDRequest
        request.nonce = viewModel.sha256(currentNonce!)

        // Present Apple authorization form
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        let svc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        guard let vc = svc else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func notNowButton(_ sender: Any) {
        viewModel.checkTown()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Save authorised user ID for future reference
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
            
            // Retrieve the secure nonce generated during Apple sign in
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }

            // Retrieve Apple identity token
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Failed to fetch identity token")
                return
            }

            // Convert Apple identity token to string
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Failed to decode identity token")
                return
            }

            // Initialize a Firebase credential using secure nonce and Apple identity token
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
            
            // Sign in with Firebase
            Auth.auth().signIn(with: firebaseCredential) { [weak self] (authResult, error) in
                if let authResult = authResult {
                    UserDefaults.standard.set(authResult.user.email, forKey: "User")
                    let changeRequest = authResult.user.createProfileChangeRequest()
                    changeRequest.displayName = appleIDCredential.fullName?.givenName
                    changeRequest.commitChanges()
                    
                    RemoteDataStore().checkUserMigration(uid: authResult.user.uid)
                    
                    self?.viewModel.checkTown()
                }
            }
        }
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

extension LoginViewController: LoginViewModelDelegate {
    func showError(title: String, description: String) {
        let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default, handler: nil)
        self.showAlert(title: title, message: description, alternativeAction: nil, acceptAction: acceptAction)
    }
    
    func navigateToTabBar() {
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? TabBarViewController
        guard let tbc = tabBarController else { return }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tbc)
    }
    
    func navigateToTownSelection() {
        let townSelectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TownSelectionViewController") as? TownSelectionViewController
        guard let tvc = townSelectionViewController else { return }
        self.navigationController?.pushViewController(tvc, animated: true)
    }
}
