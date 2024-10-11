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
    @IBOutlet var showPasswordImageView: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.tintColor = Colors.gray
            guard let image = UIImage(named: "passwordIcon") else { return }
            passwordTextField.setLeftIcon(image)
        }
    }
    @IBOutlet weak var signUpButton: CustomButton!
    
    //MARK: - Variables
    var viewModel = SignUpViewModel()
    var showPassword: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        setDelegates()
        setGestureHideKeyboard()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Functions
    func setUpUI() {
        signUpTitleLabel.font = Fonts.montserratx30
        signUpTitleLabel.text = NSLocalizedString("SIGN_UP_TITLE", comment: "")
        signUpTitleLabel.textColor = Colors.black
        
        signUpSubtitleLabel.font = Fonts.montserratx15
        signUpSubtitleLabel.text = NSLocalizedString("SIGN_UP_SUBTITLE", comment: "")
        signUpSubtitleLabel.textColor = Colors.gray
        
        emailLabel.font = Fonts.montserratx13
        emailLabel.text = NSLocalizedString("SIGN_UP_EMAIL_LABEL", comment: "")
        emailLabel.textColor = Colors.gray
        
        emailTextField.backgroundColor = Colors.lightGray
        passwordTextField.backgroundColor = Colors.lightGray
        
        guard let hidePasswordImage = UIImage(named: "eyeClosedIcon") else { return }
        showPasswordImageView.image = hidePasswordImage
        passwordTextField.isSecureTextEntry = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hidePassword))
        showPasswordImageView.isUserInteractionEnabled = true
        showPasswordImageView.addGestureRecognizer(tapGesture)
        
        passwordLabel.font = Fonts.montserratx13
        passwordLabel.text = NSLocalizedString("SIGN_UP_PASSWORD_LABEL", comment: "")
        passwordLabel.textColor = Colors.gray
        
        signUpButton.style = .filled
        signUpButton.setTitle(NSLocalizedString("SIGN_UP_BUTTON", comment: ""), for: .normal)
    }
    
    func setDelegates() {
        viewModel.delegate = self
    }
    
    func setGestureHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hidePassword() {
        guard let showPasswordImage = UIImage(named: "eyeOpenIcon"), let hidePasswordImage = UIImage(named: "eyeClosedIcon") else { return }
        showPassword = !showPassword
        if showPassword {
            self.passwordTextField.isSecureTextEntry = false
            showPasswordImageView.image = showPasswordImage
        } else {
            self.passwordTextField.isSecureTextEntry = true
            showPasswordImageView.image = hidePasswordImage
        }
        self.view.layoutIfNeeded()
    }
    
    // MARK: - IBActions
    @IBAction func signUpButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        viewModel.signUp(email: email, password: password)
    }
}

extension SignUpViewController: SignUpViewModelDelegate {
    func showError(title: String, message: String) {
        let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default, handler: nil)
        self.showAlert(title: title, message: description, alternativeAction: nil, acceptAction: acceptAction)
    }
    
    func navigateToLogin() {
        self.navigationController?.popViewController(animated: true)
    }
}
