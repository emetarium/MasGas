//
//  GasStationsOnRouteTableViewCell.swift
//  MasGas
//
//  Created by María García Torres on 27/9/24.
//

import UIKit

class GasStationsOnRouteTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet var gasStationNameLabel: UILabel!
    @IBOutlet var gasStationLocationLabel: UILabel!
    @IBOutlet var gasStationScheduleLabel: UILabel!
    @IBOutlet var fuelPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(gasStationName: String, gasStationLocation: String, gasStationSchedule: String, fuelPrice: String) {
        self.gasStationNameLabel.font = Fonts.boldx14
        self.gasStationNameLabel.textColor = Colors.darkGray
        self.gasStationNameLabel.text = gasStationName
        
        self.gasStationLocationLabel.font = Fonts.defaultx14
        self.gasStationLocationLabel.textColor = Colors.darkGray
        self.gasStationLocationLabel.text = gasStationLocation.formatName()
        
        self.gasStationScheduleLabel.font = Fonts.defaultx14
        self.gasStationScheduleLabel.textColor = Colors.darkGray
        self.gasStationScheduleLabel.text = gasStationSchedule
        
        self.fuelPriceLabel.font = Fonts.boldx14
        self.fuelPriceLabel.textColor = Colors.darkGray
        self.fuelPriceLabel.text = fuelPrice + "€"
    }
    
}
