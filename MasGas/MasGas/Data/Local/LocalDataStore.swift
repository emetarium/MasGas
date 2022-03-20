//
//  LocalDataStore.swift
//  MasGas
//
//  Created by María García Torres on 17/2/22.
//

import Foundation

class LocalDataStore {
    
    func fetchSelectedTown() -> Municipio? {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "Town") as? Data {
            let decoder = JSONDecoder()
            let town = try? decoder.decode(Municipio.self, from: data)
            return town
        }
        return nil
    }
    
    func fetchFuelsfromLocal() -> [Carburante]? {
        let defaults = UserDefaults.standard
        let fuels = defaults.array(forKey: "SavedFuelsArray")  as? [Carburante]
        return fuels
    }
    
    func fetchTownsfromLocal() -> [Municipio]? {
        let defaults = UserDefaults.standard
        let towns = defaults.array(forKey: "SavedTownsArray")  as? [Municipio]
        return towns
    }
}
