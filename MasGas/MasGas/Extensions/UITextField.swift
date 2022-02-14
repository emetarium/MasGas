//
//  UITextField.swift
//  MasGas
//
//  Created by María García Torres on 30/1/22.
//

import Foundation
import UIKit

extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        iconView.image = image
        
        let iconContainerView = UIView(frame: CGRect(x: 30, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
}
