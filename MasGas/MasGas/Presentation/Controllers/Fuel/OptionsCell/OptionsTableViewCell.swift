//
//  OptionsTableViewCell.swift
//  MasGas
//
//  Created by María García Torres on 20/8/22.
//

import UIKit

class OptionsTableViewCell: UITableViewCell {
    
    // MARK: - Variables
    @IBOutlet var optionIcon: UIImageView!
    @IBOutlet var optionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setUpUI(icon: UIImage, title: String) {
        self.contentView.backgroundColor = Colors.white
        
        self.optionIcon.image = icon
        self.optionIcon.tintColor = Colors.green
        
        self.optionLabel.textColor = Colors.black
        self.optionLabel.font = Fonts.defaultx16
        self.optionLabel.text = title
    }
    
}
