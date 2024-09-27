//
//  Repository.swift
//  MasGas
//
//  Created by María García Torres on 24/3/22.
//

import Foundation
import CoreLocation

protocol FuelsRepository {
    func fetchFuels(completion: @escaping ([Carburante]) -> Void)
    func searchFuelInTown(townIdentifier: String, fuelIdentifier: String,  completion: @escaping ([ListaEESSPrecio]?) -> Void)
    func searchFuels(fuelIdentifier: String, completion: @escaping ([ListaEESSPrecio]?) -> Void)
    func fetchLocalFuels() -> [Carburante]?
}

protocol TownsRepository {
    func saveTown(town: Municipio)
    func fetchTowns(completion: @escaping ([Municipio]) -> Void)
    func fetchSelectedTown() -> Municipio?
    func fetchLocalTowns() -> [Municipio]?
}

protocol FavoritesRepository {
    func getFavoritesList(completion: @escaping ([PreciosGasolinera]?) -> ())
    func isFavorite(gasStationID: String, completion: @escaping (Bool) -> ())
    func saveFavorite(gasStation: Gasolinera)
    func removeFavorite(gasStation: Gasolinera)
}

protocol UserRepository {
    func emailSignIn(email: String, password: String, completion: @escaping ( AuthenticationError?) -> ())
    func emailSignUp(email: String, password: String, completion: @escaping ( AuthenticationError?) -> ())
    func signOut()
    func googleSignIn(completion: @escaping (AuthenticationError?) -> ())
    func deleteAccount(completion: @escaping (AuthenticationError?) -> ())
}

protocol LocationRepository {
    func getLocation(completion: @escaping (CLLocation?) -> ())
    func calculateDistanceBetweenLocations(userLocation: CLLocation, gasStationLocation: CLLocation, completion: @escaping (Double) -> ())
    func isLocationEnabled() -> Bool
}

class Repository {
    static let shared = Repository()
    var remoteDataStore =  RemoteDataStore()
    var localDataStore = LocalDataStore()
    
    private init() {
    }
}

extension Repository: FuelsRepository {
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
    
    func searchFuelInTown(townIdentifier: String, fuelIdentifier: String,  completion: @escaping ([ListaEESSPrecio]?) -> Void) {
        remoteDataStore.getFuelPriceByTown(fuelIdentifier: fuelIdentifier, townIdentifier: townIdentifier) { listaPrecios in
            completion(listaPrecios)
        }
    }
    
    func searchFuels(fuelIdentifier: String, completion: @escaping ([ListaEESSPrecio]?) -> Void) {
        if let town = localDataStore.fetchSelectedTown() {
            remoteDataStore.getFuelPriceByTown(fuelIdentifier: fuelIdentifier, townIdentifier: town.idMunicipio) { listaPrecios in
                completion(listaPrecios)
            }
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

extension Repository: TownsRepository {
    func saveTown(town: Municipio) {
        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(town)

            UserDefaults.standard.set(data, forKey: "Town")
        } catch { }
    }
    
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
    
    func fetchSelectedTown() -> Municipio? {
        if let town = localDataStore.fetchSelectedTown() {
            return town
        } else {
            return nil
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

extension Repository: FavoritesRepository {
    func getFavoritesList(completion: @escaping ([PreciosGasolinera]?) -> ()) {
        remoteDataStore.getFavoritesList { gasolineras in
                guard let gasolineras, !gasolineras.isEmpty else {
                    completion(nil)
                    return
                }
                
                var gasStations: [PreciosGasolinera] = []
                let dispatchGroup = DispatchGroup()
                
                // Itera sobre cada gasolinera
                for gasolinera in gasolineras {
                    dispatchGroup.enter() // Entrar al grupo
                    
                    self.remoteDataStore.getFuelPriceByGasStation(gasStation: gasolinera) { precios in
                        gasStations.append(precios)
                        dispatchGroup.leave() // Salir del grupo
                    }
                }
                
                // Notificar cuando todas las tareas en el grupo se hayan completado
                dispatchGroup.notify(queue: .main) {
                    completion(gasStations)
                }
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

extension Repository: UserRepository {
    func emailSignIn(email: String, password: String, completion: @escaping ( AuthenticationError?) -> ()) {
        AuthenticationLayer.shared.emailSignIn(email: email, password: password) { result in
            switch result {
                case .success(let user):
                    UserDefaults.standard.set(user.email, forKey: "User")
                    completion(nil)
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    func emailSignUp(email: String, password: String, completion: @escaping ( AuthenticationError?) -> ()) {
        AuthenticationLayer.shared.emailSignUp(email: email, password: password) { result in
            switch result {
                case .success(let user):
                    UserDefaults.standard.set(user.email, forKey: "User")
                    completion(nil)
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    func signOut() {
        AuthenticationLayer.shared.signOut()
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    func googleSignIn(completion: @escaping (AuthenticationError?) -> ()) {
        AuthenticationLayer.shared.googleSignIn { result in
            switch result {
                case .success(let user):
                    UserDefaults.standard.set(user.email, forKey: "User")
                    completion(nil)
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    func deleteAccount(completion: @escaping (AuthenticationError?) -> ()) {
        AuthenticationLayer.shared.deleteAccount { error in
            completion(error)
        }
    }
}

extension Repository: LocationRepository {
    func getLocation(completion: @escaping (CLLocation?) -> ()) {
        LocationLayer.shared.handleLocation = { location in
            completion(location)
        }
        LocationLayer.shared.startGettingLocation()
    }
    
    func calculateDistanceBetweenLocations(userLocation: CLLocation, gasStationLocation: CLLocation, completion: (Double) -> ()) {
        LocationLayer.shared.getDistanceBetweenLocations(userLocation: userLocation, gasStationLocation: gasStationLocation) { distance in
            guard let distance = distance else {
                return
            }
            completion(distance)
        }
    }
    
    func isLocationEnabled() -> Bool {
        return LocationLayer.shared.isLocationEnabled()
    }
}

