//
//  TownSelectionTableViewCell.swift
//  MasGas
//
//  Created by María García Torres on 22/2/22.
//

import UIKit

class TownSelectionTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet var townLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(townName: String) {
        self.townLabel.font = Fonts.defaultx16
        self.townLabel.text = townName
    }
    
}
