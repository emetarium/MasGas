//
//  GasStationTableViewCell.swift
//  MasGas
//
//  Created by María García Torres on 8/3/22.
//

import UIKit

class GasStationTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet var favoriteIcon: UIImageView!
    @IBOutlet var gasStationIcon: UIImageView!
    @IBOutlet var gasStationName: UILabel!
    @IBOutlet var gasStationAddressLabel: UILabel!
    @IBOutlet var gasStationTownLabel: UILabel!
    @IBOutlet var gasPricesStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(gasStationName: String, gasStationAddress: String, gasStationTown: String, fuelPrices: [PrecioCarburante]) {
        self.favoriteIcon.tintColor = Colors.yellow
        self.gasStationIcon.tintColor = Colors.black
        self.gasStationName.text = gasStationName
        self.gasStationAddressLabel.text = gasStationAddress
        self.gasStationTownLabel.text = gasStationTown
        
        gasPricesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        fuelPrices.forEach({ price in
//            let gasPriceView = FuelPriceView()
//            gasPriceView.setUpUI(fuelPrice: price)
//            gasPricesStackView.addArrangedSubview(gasPriceView)
        })
    }
    
}
