//
//  GetLocationUseCase.swift
//  MasGas
//
//  Created by María García Torres on 24/3/22.
//

import Foundation
import CoreLocation

class GetLocationUseCase {
    func execute(completion: @escaping (CLLocation?) -> ()) {
        Repository.shared.getLocation { location in
            completion(location)
        }
    }
}
