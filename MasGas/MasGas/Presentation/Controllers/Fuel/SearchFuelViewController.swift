//
//  SearchFuelViewController.swift
//  MasGas
//
//  Created by María García Torres on 22/2/22.
//

import UIKit

class SearchFuelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - IBOutlets
    @IBOutlet var headerView: UIView!
    @IBOutlet var fuelView: UIView!
    @IBOutlet var fuelColorIcon: UIImageView!
    @IBOutlet var fuelLabel: UILabel!
    @IBOutlet var searchModeLabel: UILabel!
    @IBOutlet var fuelPricesTableView: UITableView!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Functions
    func setUpUI(fuelName: String, fuelAbb: String) {
        self.fuelLabel.text = fuelName
        self.fuelColorIcon.tintColor = UIColor(named: fuelAbb)
    }
    
    //MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
