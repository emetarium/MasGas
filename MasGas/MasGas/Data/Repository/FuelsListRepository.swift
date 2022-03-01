//
//  FuelsListRepository.swift
//  MasGas
//
//  Created by María García Torres on 17/2/22.
//

import Foundation

protocol FuelsRepository {
    func fetchFuels(completion: @escaping ([Carburante]) -> Void)
}

class FuelsListRepository: FuelsRepository {
    var remoteDataStore =  RemoteDataStore()
    var localDataStore = LocalDataStore()
    
    func fetchFuels(completion: @escaping ([Carburante]) -> Void) {
        if let fuels = fetchLocalFuels() {
            completion(fuels)
        } else {
            remoteDataStore.getFuelsData(completionHandler: { carburantes in
                if let carburantes = carburantes {
                    do {
                        let encoder = JSONEncoder()

                        let data = try encoder.encode(carburantes)

                        UserDefaults.standard.set(data, forKey: "SavedFuelsArray")
                    } catch { }
                    completion(carburantes)
                }
            })
        }
    }
    
    func fetchLocalFuels() -> [Carburante]? {
        if let fuels = localDataStore.fetchFuelsfromLocal() {
            return fuels
        } else {
            return nil
        }
    }
}
