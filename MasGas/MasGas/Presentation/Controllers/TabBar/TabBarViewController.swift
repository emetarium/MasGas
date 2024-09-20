//
//  TabBarViewController.swift
//  MasGas
//
//  Created by María García Torres on 15/2/22.
//

import UIKit
import CoreLocation

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setUpUI()
        setUpTabs()
    }
    
    func setUpTabs() {
        guard let gasStationsIcon = UIImage(named: "gasStationIcon"), let fuelPumpIcon = UIImage(named: "fuelPumpIcon") else { return }
        
        let fvc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FuelsViewController") as? FuelsViewController
        guard let fuelsViewController = fvc else { return }
        let fuelsBarItem = UITabBarItem(title: NSLocalizedString("FUEL_SCREEN_TAB_BAR_TITLE", comment: ""), image: fuelPumpIcon.withTintColor(Colors.gray), selectedImage: fuelPumpIcon.withTintColor(Colors.green))
        fuelsViewController.tabBarItem = fuelsBarItem
        
        let gvc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FavoriteGasStationsViewController") as? FavoriteGasStationsViewController
        guard let favoriteGasStationsViewController = gvc else { return }
        let favoriteGasStationsBarItem = UITabBarItem(title: NSLocalizedString("GAS_STATIONS_SCREEN_TAB_BAR_TITLE", comment: ""), image: gasStationsIcon.withTintColor(Colors.gray), selectedImage: gasStationsIcon.withTintColor(Colors.green))
        favoriteGasStationsViewController.tabBarItem = favoriteGasStationsBarItem
        
        self.navigationController?.isNavigationBarHidden = true
        self.viewControllers = [favoriteGasStationsViewController, fuelsViewController]
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
