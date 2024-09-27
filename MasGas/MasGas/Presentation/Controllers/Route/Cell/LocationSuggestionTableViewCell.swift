//
//  LocationSuggestionTableViewCell.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import UIKit

class LocationSuggestionTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(name: String, subtitle: String) {
        self.nameLabel.font = Fonts.boldx14
        self.nameLabel.textColor = Colors.darkGray
        self.nameLabel.text = name
        
        self.subtitleLabel.font = Fonts.defaultx14
        self.subtitleLabel.textColor = Colors.darkGray
        self.subtitleLabel.text = subtitle
    }
    
}
