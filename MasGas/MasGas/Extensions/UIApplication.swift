//
//  UIApplication.swift
//  MasGas
//
//  Created by María García Torres on 31/5/24.
//

import Foundation
import UIKit

extension UIApplication {
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
}
