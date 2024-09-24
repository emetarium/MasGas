//
//  AboutViewController.swift
//  MasGas
//
//  Created by María García Torres on 20/8/22.
//

import UIKit

class AboutViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var navigationBarItem: UINavigationItem!
    @IBOutlet var appVersionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    func setUpUI() {
        self.view.backgroundColor = Colors.darkGray
        
        let replace: [String : String] = ["[version]" : UIApplication.appVersion()]
        self.appVersionLabel.font = Fonts.defaultx14
        self.appVersionLabel.text = NSLocalizedString("APP_VERSION_LABEL", comment: "").replace(occurrences: replace)
        self.appVersionLabel.textColor = Colors.white
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = Colors.darkGray
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat", size: 15)!, NSAttributedString.Key.foregroundColor: Colors.white]
        self.navigationBarItem.title = NSLocalizedString("ABOUT_TITLE", comment: "")
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(popToPrevious))
        barButtonItem.tintColor = Colors.white
        self.navigationBarItem.leftBarButtonItem = barButtonItem
    }
    
    @objc private func popToPrevious() {
        self.navigationController?.popViewController(animated: true)
    }
}
