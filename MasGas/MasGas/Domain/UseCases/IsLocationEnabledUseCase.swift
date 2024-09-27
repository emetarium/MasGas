//
//  IsLocationEnabledUseCase.swift
//  MasGas
//
//  Created by María García Torres on 22/4/22.
//

import Foundation
import CoreLocation

class IsLocationEnabledUseCase {
    func execute() -> Bool {
        return Repository.shared.isLocationEnabled()
    }
}
