//
//  TownsListRepository.swift
//  MasGas
//
//  Created by María García Torres on 22/2/22.
//

import Foundation

protocol TownsRepository {
    func fetchTowns(completion: @escaping ([Municipio]) -> Void)
}

class TownsListRepository: TownsRepository {
    var remoteDataStore =  RemoteDataStore()
    var localDataStore = LocalDataStore()
    
    func fetchTowns(completion: @escaping ([Municipio]) -> Void) {
        if let towns = fetchLocalTowns() {
            completion(towns)
        } else {
            remoteDataStore.getTownsData(completionHandler: { municipios in
                if let municipios = municipios {
                    do {
                        let encoder = JSONEncoder()

                        let data = try encoder.encode(municipios)

                        UserDefaults.standard.set(data, forKey: "SavedTownsArray")
                    } catch { }
                    completion(municipios)
                }
            })
        }
    }
    
    func fetchLocalTowns() -> [Municipio]? {
        if let towns = localDataStore.fetchTownsfromLocal() {
            return towns
        } else {
            return nil
        }
    }
}
