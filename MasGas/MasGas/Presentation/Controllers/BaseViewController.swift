//
//  BaseViewController.swift
//  MasGas
//
//  Created by María García Torres on 30/3/22.
//

import UIKit

class BaseViewController: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showLoading() {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.color = Colors.green
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        print("aqui")
        self.activityIndicator.stopAnimating()
        print("ya")
    }
}
