//
//  SignUpViewController.swift
//  MasGas
//
//  Created by María García Torres on 30/1/22.
//

import UIKit

class SignUpViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.tintColor = .black
            guard let image = UIImage(named: "emailIcon") else { return }
            emailTextField.setIcon(image)
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.tintColor = .black
            guard let image = UIImage(named: "passwordIcon") else { return }
            passwordTextField.setIcon(image)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
