//
//  SignUpViewController.swift
//  MasGas
//
//  Created by María García Torres on 30/1/22.
//

import UIKit

protocol SignUpProtocol {
    func navigateToLogin()
}

class SignUpViewController: BaseViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var signUpTitleLabel: UILabel!
    @IBOutlet weak var signUpSubtitleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.tintColor = Colors.gray
            guard let image = UIImage(named: "emailIcon") else { return }
            emailTextField.setLeftIcon(image)
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.tintColor = Colors.gray
            guard let image = UIImage(named: "passwordIcon") else { return }
            passwordTextField.setLeftIcon(image)
        }
    }
    @IBOutlet weak var signUpButton: UIButton!
    
    //MARK: - Variables
    var presenter: SignUpPresenter<SignUpViewController>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SignUpPresenter(self)
        setUpUI()
        setGestureHideKeyboard()
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
        
        emailTextField.backgroundColor = Colors.lightGray
        passwordTextField.backgroundColor = Colors.lightGray
        
        passwordLabel.text = NSLocalizedString("SIGN_UP_PASSWORD_LABEL", comment: "")
        passwordLabel.textColor = Colors.gray
        
        signUpButton.backgroundColor = Colors.green
        signUpButton.layer.cornerRadius = 4
        signUpButton.setTitleColor(Colors.white, for: .normal)
        signUpButton.setTitle(NSLocalizedString("SIGN_UP_BUTTON", comment: ""), for: .normal)
        signUpButton.tintColor = Colors.green
    }
    
    func setGestureHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: - IBActions
    @IBAction func signUpButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        presenter?.signUp(email: email, password: password)
    }
}

extension SignUpViewController: SignUpProtocol {
    func navigateToLogin() {
        self.navigationController?.popViewController(animated: true)
    }
}
