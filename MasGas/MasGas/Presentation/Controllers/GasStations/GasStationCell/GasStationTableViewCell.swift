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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(gasStationName: String) {
        self.favoriteIcon.tintColor = Colors.yellow
        self.gasStationIcon.tintColor = Colors.black
        self.gasStationName.text = gasStationName
    }
    
}
