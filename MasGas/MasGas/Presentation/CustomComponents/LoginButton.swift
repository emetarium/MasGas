//
//  LoginButton.swift
//  MasGas
//
//  Created by María García Torres on 20/8/22.
//

import UIKit

enum LoginButtonStyle {
    case filled
    case bordered
}

class LoginButton: UIButton {
    
    var style: LoginButtonStyle = .filled {
        didSet {
            setUpUI()
        }
    }

    var titleText: String? {
        didSet {
            self.setTitle(titleText, for: .normal)
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setUpUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpUI()
    }
    
    // MARK: - Methods
    func setUpUI() {
        self.clipsToBounds = true
        self.frame.size.height = 40
        self.layer.cornerRadius = 20
        
        switch style {
        case .filled:
            self.tintColor = Colors.green
            self.backgroundColor = Colors.green
            self.setTitleColor(Colors.white, for: .normal)
        case .bordered:
            self.tintColor = Colors.white
            self.backgroundColor = Colors.white
            self.setTitleColor(Colors.black, for: .normal)
            self.layer.borderWidth = 1
            self.layer.borderColor = Colors.mediumLightGray?.cgColor
        }
    }

}
