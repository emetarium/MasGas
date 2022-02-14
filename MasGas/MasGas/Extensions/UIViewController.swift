//
//  UIViewController.swift
//  MasGas
//
//  Created by María García Torres on 27/1/22.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, alternativeAction: UIAlertAction?, acceptAction: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(acceptAction)
        if let alternativeAction = alternativeAction {
            alert.addAction(alternativeAction)
        }
        self.present(alert, animated: true)
    }
    
    func showActionSheet(title: String, message: String, action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}
