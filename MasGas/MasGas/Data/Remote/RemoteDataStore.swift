//
//  RemoteDataStore.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import Foundation
import Firebase
import CoreLocation
import CryptoKit

protocol APIDataStore {
    func getTownsData(completionHandler: @escaping ([Municipio]?) -> ())
    func getFuelsData(completionHandler: @escaping ([Carburante]?) -> ())
    func getFuelPriceByTown(fuelIdentifier: String, townIdentifier: String, completionHandler: @escaping ([ListaEESSPrecio]?) -> ())
}

class RemoteDataStore: APIDataStore {
    var ref: DatabaseReference! = Database.database().reference()
    
    func getTownsData(completionHandler: @escaping ([Municipio]?) -> ()) {
        guard let url = URL(string: APIUrls.urlMunicipios.rawValue) else { return }
        let urlRequest = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            guard error == nil, let urlResponse = urlResponse as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            let townDecode = try! jsonDecoder.decode([Municipio].self, from: data)
            completionHandler(townDecode)
        }
        task.resume()
    }
    
    func getFuelsData(completionHandler: @escaping ([Carburante]?) -> ()) {
        guard let url = URL(string: APIUrls.urlCarburantes.rawValue) else { return }
        let urlRequest = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            guard error == nil, let urlResponse = urlResponse as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            let fuelDecode = try! jsonDecoder.decode([Carburante].self, from: data)
            completionHandler(fuelDecode)
        }
        task.resume()
    }
    
    func getFuelPriceByTown(fuelIdentifier: String, townIdentifier: String, completionHandler: @escaping ([ListaEESSPrecio]?) -> ()) {
        var replacedString = APIUrls.urlBusquedaMunicipiosCarburantes.rawValue.replace(occurrences: ["{IDMUNICIPIO}" : townIdentifier])
        replacedString = replacedString.replace(occurrences: ["{IDPRODUCTO}" : fuelIdentifier])
        guard let url = URL(string: replacedString) else { return }
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            guard error == nil, let urlResponse = urlResponse as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else { return }
            
                let jsonDecoder = JSONDecoder()
            
                let queryDecode = try! jsonDecoder.decode(Consulta.self, from: data)
                var listaPrecios: [ListaEESSPrecio] = []
                queryDecode.listaPrecio.enumerated().forEach { element in
                    if element.element.tipoVenta == "P" {
                        listaPrecios.append(element.element)
                    }
                }
                completionHandler(listaPrecios)
        }
        task.resume()
    }
    
    func saveFavorite(gasStation: Gasolinera) {
        guard let user = Auth.auth().currentUser else { return }
        
        ref.child("users").child(user.uid).child("\(gasStation.id)/nombre").setValue(gasStation.nombre)
        ref.child("users").child(user.uid).child("\(gasStation.id)/direccion").setValue(gasStation.direccion)
        ref.child("users").child(user.uid).child("\(gasStation.id)/municipio").setValue(gasStation.municipio)
        ref.child("users").child(user.uid).child("\(gasStation.id)/longitud").setValue(String(format: "%f", gasStation.ubicacion.coordinate.longitude))
        ref.child("users").child(user.uid).child("\(gasStation.id)/latitud").setValue(String(format: "%f", gasStation.ubicacion.coordinate.latitude))
    }
    
    func removeFavorite(gasStation: Gasolinera) {
        guard let user = Auth.auth().currentUser else { return }
        
        ref.child("users").child(user.uid).child(gasStation.id).removeValue()
    }
    
    func getFavoritesList(completion: @escaping ([Gasolinera]?) -> ()) {
        var favoritesList: [Gasolinera] = []
        
        guard let user = Auth.auth().currentUser else {
            completion(nil)
            return
        }
        
        let postRef = ref.child("users").child(user.uid)
        postRef.observeSingleEvent(of: .value, with: { snapshot in
            let allFavorites = snapshot.children.allObjects as! [DataSnapshot]
            for favorite in allFavorites {
                let id = favorite.key
                guard let name = favorite.childSnapshot(forPath: "nombre").value as? String, let address = favorite.childSnapshot(forPath: "direccion").value as? String, let town = favorite.childSnapshot(forPath: "municipio").value as? String, let longitude = favorite.childSnapshot(forPath: "longitud").value as? String, let latitude = favorite.childSnapshot(forPath: "latitud").value as? String else { return }
                let location = CLLocation(latitude: (latitude as NSString).doubleValue, longitude: (longitude as NSString).doubleValue)
                let gasStation = Gasolinera(nombre: name, ubicacion: location, direccion: address, municipio: town, favorita: true, id: id)
                favoritesList.append(gasStation)
            }
            completion(favoritesList)
        })
    }
    
    func isFavorite(gasStationID: String, completion: @escaping (Bool) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        
        ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(gasStationID){
                completion(true)
            } else{
                completion(false)
            }
        })
    }
}

// Código para migrar datos en base de datos
extension RemoteDataStore {
    func checkUserMigration(uid: String) {
        let userRef = Database.database().reference().child("users").child(uid)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                // Los datos ya están migrados
                print("Datos del usuario ya migrados.")
            } else {
                // Los datos aún no están migrados
                self.migrateUserData(uid: uid)
            }
        }
    }
    
    // Función para migrar los datos del usuario desde el identificador antiguo al UID
    func migrateUserData(uid: String) {
        // Referencia a la base de datos de usuarios con el identificador basado en el email modificado
        guard var user = UserDefaults.standard.string(forKey: "User") else { return }
        user = user.components(separatedBy: ("."))[0]
        let oldRef = Database.database().reference().child(user)
        
        oldRef.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot], let childSnapshot = children.first else {
                print("No se encontraron datos antiguos para migrar.")
                return
            }
            
            for child in children {
                // Para cada identificador de datos del usuario
                let dataId = child.key
                let dataRef = child.ref
                
                // Leer los datos para este identificador
                dataRef.observeSingleEvent(of: .value) { dataSnapshot in
                    if let data = dataSnapshot.value as? [String: Any] {
                        // Crear una referencia al nuevo nodo del usuario basado en el UID
                        let newRef = Database.database().reference().child("users").child(uid).child(dataId)
                        
                        // Escribir los datos bajo el nuevo identificador (UID)
                        newRef.setValue(data) { error, _ in
                            if let error = error {
                                print("Error al migrar datos del usuario \(user): \(error)")
                            } else {
                                // Eliminar los datos antiguos
                                self.deleteOldUserData(for: childSnapshot.key)
                            }
                        }
                    } else {
                        print("No se encontraron datos antiguos para migrar.")
                    }
                }
            }
        }
    }
    
    // Función para eliminar los datos del usuario bajo el identificador antiguo basado en el email
    func deleteOldUserData(for currentIdentifier: String) {
        guard var user = UserDefaults.standard.string(forKey: "User") else { return }
        user = user.components(separatedBy: ("."))[0]
        let oldRef = Database.database().reference().child(user)
        oldRef.removeValue { error, _ in
            if let error = error {
                print("Error al eliminar datos antiguos: \(error)")
            } else {
                print("Datos antiguos eliminados correctamente.")
            }
        }
    }
}
