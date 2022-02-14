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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK: - IBActions
    @IBAction func loginButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        if AuthenticationLayer.shared.emailSignIn(email: email, password: password) {
            let hvc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
            guard let vc = hvc else { return }
            self.navigationController?.pushViewController(vc, animated: true)
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

