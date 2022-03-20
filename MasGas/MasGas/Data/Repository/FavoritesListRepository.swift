//
//  FavoritesListRepository.swift
//  MasGas
//
//  Created by María García Torres on 14/3/22.
//

import Foundation

class FavoritesListRepository {
    var remoteDataStore =  RemoteDataStore()
    
    func getFavoritesList(completion: @escaping ([Gasolinera]?) -> ()) {
        remoteDataStore.getFavoritesList { gasolineras in
            completion(gasolineras)
        }
    }
    
    func isFavorite(gasStationID: String, completion: @escaping (Bool) -> ()) {
        remoteDataStore.isFavorite(gasStationID: gasStationID) { result in
            completion(result)
        }
    }
    
    func saveFavorite(gasStation: Gasolinera) {
        remoteDataStore.saveFavorite(gasStation: gasStation)
    }
    
    func removeFavorite(gasStation: Gasolinera) {
        remoteDataStore.removeFavorite(gasStation: gasStation)
    }
}
