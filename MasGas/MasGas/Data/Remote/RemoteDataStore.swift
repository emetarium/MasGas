//
//  RemoteDataStore.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import Foundation
import Firebase
import CoreLocation

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
            
//                let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//                print(prettyPrintedString)

            
                let queryDecode = try! jsonDecoder.decode(Consulta.self, from: data)

                completionHandler(queryDecode.listaPrecio)
        }
        task.resume()
    }
    
    func saveFavorite(gasStation: Gasolinera) {
        guard var user = UserDefaults.standard.string(forKey: "User") else { return }
        user = user.components(separatedBy: ("@"))[0]
        ref.child("\(user)/\(gasStation.id)/nombre").setValue(gasStation.nombre)
        ref.child("\(user)/\(gasStation.id)/longitud").setValue(String(format: "%f", gasStation.ubicacion.coordinate.longitude))
        ref.child("\(user)/\(gasStation.id)/latitud").setValue(String(format: "%f", gasStation.ubicacion.coordinate.latitude))
    }
    
    func removeFavorite(gasStation: Gasolinera) {
        guard var user = UserDefaults.standard.string(forKey: "User") else { return }
        user = user.components(separatedBy: ("@"))[0]
        ref.child("\(user)/\(gasStation.id)").removeValue()
    }
    
    func getFavoritesList(completion: @escaping ([Gasolinera]?) -> ()) {
        var favoritesList: [Gasolinera] = []
        guard var user = UserDefaults.standard.string(forKey: "User") else { return }
        user = user.components(separatedBy: ("@"))[0]
        
        let postRef = self.ref.child(user) //self.ref points to my firebase
        postRef.observeSingleEvent(of: .value, with: { snapshot in
            let allFavorites = snapshot.children.allObjects as! [DataSnapshot]
            for favorite in allFavorites {
                let id = favorite.key
                guard let name = favorite.childSnapshot(forPath: "nombre").value as? String, let longitude = favorite.childSnapshot(forPath: "longitud").value as? String, let latitude = favorite.childSnapshot(forPath: "latitud").value as? String else { return }
                let location = CLLocation(latitude: (latitude as NSString).doubleValue, longitude: (longitude as NSString).doubleValue)
                let gasStation = Gasolinera(nombre: name, ubicacion: location, favorita: true, id: id)
                favoritesList.append(gasStation)
            }
            completion(favoritesList)
        })
    }
    
    func isFavorite(gasStationID: String, completion: @escaping (Bool) -> ()) {
        guard var user = UserDefaults.standard.string(forKey: "User") else { return }
        user = user.components(separatedBy: ("@"))[0]
        
        ref.child(user).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(gasStationID){
                completion(true)
            } else{
                completion(false)
            }
        })
    }
}
