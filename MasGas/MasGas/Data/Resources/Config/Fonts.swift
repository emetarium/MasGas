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
    
    static var montserratx30: UIFont {
        return UIFont(name: "Montserrat", size: 30) ?? UIFont.boldSystemFont(ofSize: 30)
    }
    
    static var montserratx24: UIFont {
        return UIFont(name: "Montserrat", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
    }
    
    static var montserratx17: UIFont {
        return UIFont(name: "Montserrat", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
    }
    
    static var montserratx15: UIFont {
        return UIFont(name: "Montserrat", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    }
    
    static var montserratx14: UIFont {
        return UIFont(name: "Montserrat", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    }
    
    static var montserratx13: UIFont {
        return UIFont(name: "Montserrat", size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
    }
    
    static var montserratx12: UIFont {
        return UIFont(name: "Montserrat", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
    }
    
    // Montserrat Bold
    static var montserratBoldx20: UIFont {
        return UIFont(name: "Montserrat-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
    }
    
    static var montserratBoldx17: UIFont {
        return UIFont(name: "Montserrat-Bold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
    }
    
    // System Font
    static var defaultx16: UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    static var defaultx14: UIFont {
        return UIFont.systemFont(ofSize: 14)
    }
    
    // System Font Bold
    static var boldx14: UIFont {
        return UIFont.boldSystemFont(ofSize: 14)
    }
    
    static var boldx16: UIFont {
        return UIFont.boldSystemFont(ofSize: 16)
    }
}
