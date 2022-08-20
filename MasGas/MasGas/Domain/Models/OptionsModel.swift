//
//  OptionsModel.swift
//  MasGas
//
//  Created by María García Torres on 20/8/22.
//

import Foundation
import UIKit

enum LoggedOptions: Int, CaseIterable, CustomStringConvertible {
    case logout
    case deleteAccount
    case about
    
    var description: String {
        switch self {
        case .logout:
            return NSLocalizedString("LOGOUT_OPTION_TITLE", comment: "")
        case .deleteAccount:
            return NSLocalizedString("DELETE_ACCOUNT_OPTION_TITLE", comment: "")
        case .about:
            return NSLocalizedString("ABOUT_OPTION_TITLE", comment: "")
        }
    }
    
    var icon: UIImage {
        switch self {
        case .logout:
            return UIImage(named: "logoutIcon") ?? UIImage()
        case .deleteAccount:
            return UIImage(named: "cancelIcon") ?? UIImage()
        case .about:
            return UIImage(named: "infoIcon") ?? UIImage()
        }
    }
}

enum NotLoggedOptions: Int, CaseIterable, CustomStringConvertible {
    case login
    case about
    
    var description: String {
        switch self {
        case .about:
            return NSLocalizedString("ABOUT_OPTION_TITLE", comment: "")
        case .login:
            return NSLocalizedString("LOGIN_OPTION_TITLE", comment: "")
        }
    }
    
    var icon: UIImage {
        switch self {
        case .about:
            return UIImage(named: "infoIcon") ?? UIImage()
        case .login:
            return UIImage(named: "userIcon") ?? UIImage()
        }
    }
}
