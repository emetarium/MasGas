//
//  FuelTableViewCell.swift
//  MasGas
//
//  Created by María García Torres on 17/2/22.
//

import UIKit

class FuelTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet var colorIcon: UIImageView!
    @IBOutlet var fuelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpUI(fuelName: String, fuelAbb: String) {
        self.fuelLabel.text = fuelName
        self.colorIcon.tintColor = UIColor(named: fuelAbb)
    }
    
}
