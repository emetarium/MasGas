//
//  TabBarViewController.swift
//  MasGas
//
//  Created by María García Torres on 15/2/22.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    var fuels: [Carburante]?
    var towns: [Municipio]?
    var town: Municipio?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setUpUI()
        setUpTabs()
        // Do any additional setup after loading the view.
    }
    
    func setUpTabs() {
        guard let gasStationsIcon = UIImage(named: "gasStationIcon"), let fuelPumpIcon = UIImage(named: "fuelPumpIcon"), let green = Colors.green, let gray = Colors.gray else { return }
        
        let hvc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        guard let homeViewController = hvc else { return }
        let homeBarItem = UITabBarItem(title: NSLocalizedString("FUEL_SCREEN_TAB_BAR_TITLE", comment: ""), image: fuelPumpIcon.withTintColor(gray), selectedImage: fuelPumpIcon.withTintColor(green))
        guard let fuels = fuels, let towns = towns else { return }
        homeViewController.fuels = fuels
        homeViewController.town = town
        homeViewController.towns = towns
        homeViewController.tabBarItem = homeBarItem
        
        let gvc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "GasStationsViewController") as? GasStationsViewController
        guard let gasStationsViewController = gvc else { return }
        let gasStationsBarItem = UITabBarItem(title: NSLocalizedString("GAS_STATIONS_SCREEN_TAB_BAR_TITLE", comment: ""), image: gasStationsIcon.withTintColor(gray), selectedImage: gasStationsIcon.withTintColor(green))
        gasStationsViewController.tabBarItem = gasStationsBarItem
        
        self.navigationController?.isNavigationBarHidden = true
        self.viewControllers = [homeViewController, gasStationsViewController]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setUpUI() {
        self.tabBar.backgroundColor = Colors.lightGray
        self.tabBar.unselectedItemTintColor = Colors.gray
        self.tabBar.tintColor = Colors.green
        
        tabBar.layer.shadowColor = UIColor.lightGray.cgColor
        tabBar.layer.shadowOpacity = 0.5
        tabBar.layer.shadowOffset = CGSize.zero
        tabBar.layer.shadowRadius = 5
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.layer.borderWidth = 0
        self.tabBar.clipsToBounds = false
        self.tabBar.backgroundColor = UIColor.white
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
    }

}
