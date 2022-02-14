//
//  SignUpViewController.swift
//  MasGas
//
//  Created by María García Torres on 30/1/22.
//

import UIKit

class SignUpViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var signUpTitleLabel: UILabel!
    @IBOutlet weak var signUpSubtitleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.tintColor = Colors.gray
            guard let image = UIImage(named: "emailIcon") else { return }
            emailTextField.setIcon(image)
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.tintColor = Colors.gray
            guard let image = UIImage(named: "passwordIcon") else { return }
            passwordTextField.setIcon(image)
        }
    }
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Functions
    func setUpUI() {
        signUpTitleLabel.text = NSLocalizedString("SIGN_UP_TITLE", comment: "")
        signUpTitleLabel.textColor = Colors.black
        
        signUpSubtitleLabel.text = NSLocalizedString("SIGN_UP_SUBTITLE", comment: "")
        signUpSubtitleLabel.textColor = Colors.gray
        
        emailLabel.text = NSLocalizedString("SIGN_UP_EMAIL_LABEL", comment: "")
        emailLabel.textColor = Colors.gray
        
        passwordLabel.text = NSLocalizedString("SIGN_UP_PASSWORD_LABEL", comment: "")
        passwordLabel.textColor = Colors.gray
        
        signUpButton.setTitle(NSLocalizedString("SIGN_UP_BUTTON", comment: ""), for: .normal)
        signUpButton.tintColor = Colors.green
    }
    
    // MARK: - IBActions
    @IBAction func signUpButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        AuthenticationLayer.shared.emailSignUp(email: email, password: password)
    }
}
