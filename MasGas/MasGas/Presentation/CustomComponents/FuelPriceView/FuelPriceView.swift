//
//  FuelPriceView.swift
//  MasGas
//
//  Created by María García Torres on 8/9/24.
//

import UIKit

class FuelPriceView: UIView {

    // MARK: - IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet var fuelNameLabel: UILabel!
    @IBOutlet var fuelPriceLabel: UILabel!
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private functions
    private func commonInit() {
        Bundle.main.loadNibNamed("FuelPriceView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.layer.cornerRadius = 10
    }
    
    func setUpUI(fuelPrice: PrecioCarburante) {
        contentView.backgroundColor = UIColor(named: fuelPrice.carburante.nombreProductoAbreviatura)
        
        fuelNameLabel.textColor = Colors.white
        fuelNameLabel.text = NSLocalizedString(fuelPrice.carburante.nombreProductoAbreviatura, comment: "")
        fuelNameLabel.textAlignment = .center
        
        fuelPriceLabel.textColor = Colors.white
        fuelPriceLabel.text = ("\(fuelPrice.precio)€")
        fuelPriceLabel.textAlignment = .center
    }
}
