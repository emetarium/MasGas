//
//  Fonts.swift
//  MasGas
//
//  Created by María García Torres on 20/9/24.
//

import Foundation
import UIKit

enum Fonts {
    
    // Montserrat Regular
    static var montserratx35: UIFont {
        return UIFont(name: "Montserrat", size: 35) ?? UIFont.boldSystemFont(ofSize: 35)
    }
    
    static var montserratx14: UIFont {
        return UIFont(name: "Montserrat", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    }
    
    // Montserrat Bold
    static var montserratBoldx20: UIFont {
        return UIFont(name: "Montserrat-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
    }
    
    // Muli
    static var mulix14: UIFont {
        return UIFont(name: "MuliLight", size: 14) ?? UIFont.systemFont(ofSize: 14)
    }
}
