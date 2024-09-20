//
//  FuelPriceCollectionViewCell.swift
//  MasGas
//
//  Created by María García Torres on 16/9/24.
//

import UIKit

class FuelPriceCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet var fuelNameView: UIView!
    @IBOutlet var fuelNameLabel: UILabel!
    @IBOutlet var fuelPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpUI(fuelName: String, fuelPrice: String, fuelColor: UIColor) {
        self.layer.cornerRadius = 2
        self.layer.borderWidth = 1
        self.layer.borderColor = fuelColor.cgColor
        
        self.fuelNameView.backgroundColor = fuelColor
        
        self.fuelNameLabel.font = Fonts.montserratx14
        self.fuelNameLabel.textAlignment = .center
        self.fuelNameLabel.text = NSLocalizedString(fuelName, comment: "")
        
        self.fuelPriceLabel.font = Fonts.mulix14
        self.fuelPriceLabel.textAlignment = .center
        self.fuelPriceLabel.text = "\(fuelPrice)€"
    }

}
