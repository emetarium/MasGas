//
//  LoginViewController.swift
//  MasGas
//
//  Created by María García Torres on 26/1/22.
//

import UIKit
import GoogleSignIn
import Firebase

protocol LoginProtocol {
    func navigateToHome()
    func navigateToTownSelection()
    func getFuels(fuels: [Carburante])
    func getTowns(towns: [Municipio])
}

class LoginViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    //MARK: - Variables
    var presenter: LoginPresenter<LoginViewController>?
    var fuels: [Carburante]?
    var towns: [Municipio]?
    var selectedTown: Municipio?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = LoginPresenter(self)
        fetchData()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter?.checkLogin()
    }
    
    //MARK: - Functions
    func fetchData() {
        presenter?.fetchFuels()
        presenter?.fetchTowns()
        presenter?.fetchSelectedTown()
    }
    
    func setUpUI() {
        emailTextField.backgroundColor = Colors.lightGray
        passwordTextField.backgroundColor = Colors.lightGray
        
        loginButton.tintColor = Colors.green
        loginButton.setTitle(NSLocalizedString("LOGIN_BUTTON", comment: ""), for: .normal)
        
        googleLoginButton.setTitle(NSLocalizedString("GOOGLE_LOGIN_BUTTON", comment: ""), for: .normal)
        googleLoginButton.tintColor = Colors.green
        
        signUpLabel.text = NSLocalizedString("SIGN_UP_LABEL", comment: "")
        
        signUpButton.setTitle(NSLocalizedString("SIGN_UP_BUTTON", comment: ""), for: .normal)
        signUpButton.tintColor = Colors.green
    }

    //MARK: - IBActions
    @IBAction func loginButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        presenter?.emailLogin(email: email, password: password)
    }
    
    @IBAction func googleLoginButton(_ sender: Any) {
        presenter?.googleLogin()
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        let svc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        guard let vc = svc else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: LoginProtocol {
    func navigateToHome() {
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? TabBarViewController
        guard let tbc = tabBarController, let fuels = fuels, let town = selectedTown else { return }
        tbc.fuels = fuels
        tbc.towns = towns
        tbc.town = town
        self.navigationController?.pushViewController(tbc, animated: true)
    }
    
    func navigateToTownSelection() {
        let townSelectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TownSelectionViewController") as? TownSelectionViewController
        guard let tvc = townSelectionViewController, let fuels = fuels, let towns = towns else { return }
        tvc.towns = towns
        tvc.fuels = fuels
        self.navigationController?.pushViewController(tvc, animated: true)
    }
    
    func getFuels(fuels: [Carburante]) {
        self.fuels = fuels
    }
    
    func getTowns(towns: [Municipio]) {
        self.towns = towns
    }
    
    func getSelectedTown(town: Municipio) {
        self.selectedTown = town
    }
}
