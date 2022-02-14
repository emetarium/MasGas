//
//  LoginViewController.swift
//  MasGas
//
//  Created by María García Torres on 26/1/22.
//

import UIKit
import GoogleSignIn
import Firebase

class LoginViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isUserLogged() {
            navigateToHome()
        }
    }
    
    //MARK: - Functions
    func setUpUI() {
        loginButton.tintColor = Colors.green
        loginButton.setTitle(NSLocalizedString("LOGIN_BUTTON", comment: ""), for: .normal)
        
        googleLoginButton.setTitle(NSLocalizedString("GOOGLE_LOGIN_BUTTON", comment: ""), for: .normal)
        googleLoginButton.tintColor = Colors.green
        
        signUpLabel.text = NSLocalizedString("SIGN_UP_LABEL", comment: "")
        
        signUpButton.setTitle(NSLocalizedString("SIGN_UP_BUTTON", comment: ""), for: .normal)
        signUpButton.tintColor = Colors.green
    }
    
    func isUserLogged() -> Bool{
        let userSession = UserDefaults.standard
        if userSession.object(forKey: "Email") != nil {
            return true
        }
        else {
            return false
        }
    }
    
    func navigateToHome() {
        let hvc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        guard let vc = hvc else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    //MARK: - IBActions
    @IBAction func loginButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        AuthenticationLayer.shared.emailSignIn(email: email, password: password)
        if isUserLogged() {
            navigateToHome()
        }
        else {
            let acceptAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
            self.showAlert(title: "Datos incorrectos", message: "Los datos del usuario son incorrectos", alternativeAction: nil, acceptAction: acceptAction)
        }
    }
    
    @IBAction func googleLoginButton(_ sender: Any) {
        AuthenticationLayer.shared.googleSignIn()
        let hvc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        guard let vc = hvc else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        let svc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        guard let vc = svc else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

