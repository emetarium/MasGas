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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(gasStationName: String, gasStationAddress: String, gasStationTown: String) {
        self.favoriteIcon.tintColor = Colors.yellow
        self.gasStationIcon.tintColor = Colors.black
        
        self.gasStationName.font = Fonts.montserratBoldx17
        self.gasStationName.text = gasStationName
        
        self.gasStationAddressLabel.font = Fonts.defaultx16
        self.gasStationAddressLabel.text = gasStationAddress
        
        self.gasStationTownLabel.font = Fonts.defaultx16
        self.gasStationTownLabel.text = gasStationTown
    }
    
}
