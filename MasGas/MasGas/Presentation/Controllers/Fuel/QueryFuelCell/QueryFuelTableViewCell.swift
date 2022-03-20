//
//  QueryFuelTableViewCell.swift
//  MasGas
//
//  Created by María García Torres on 1/3/22.
//

import UIKit

class QueryFuelTableViewCell: UITableViewCell {
    
    //MARK: - IBActions
    @IBOutlet var fuelPrice: UILabel!
    @IBOutlet var fuelIcon: UIImageView!
    @IBOutlet var gasStationName: UILabel!
    @IBOutlet var gasStationSchedule: UILabel!
    @IBOutlet var backgroundCellView: UIView!
    @IBOutlet var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(price: String, gasStationName: String, gasStationSchedule: String, distanceToGasStation: Double){
        self.contentView.backgroundColor = Colors.lightGray
        self.backgroundCellView.layer.cornerRadius = 10
        self.fuelIcon.tintColor = Colors.black
        self.fuelPrice.text = price + "/L"
        self.gasStationName.text = gasStationName
        self.gasStationSchedule.text = gasStationSchedule
        self.distanceLabel.text = "\(String(format:"%.02f", distanceToGasStation)) km"
    }
    
}
