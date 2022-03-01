//
//  RemoteDataStore.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import Foundation

protocol APIDataStore {
    func getTownsData(completionHandler: @escaping ([Municipio]?) -> ())
    func getFuelsData(completionHandler: @escaping ([Carburante]?) -> ())
    func getFuelPriceByTown(fuelIdentifier: String, townIdentifier: String, completionHandler: @escaping ([Consulta]?) -> ())
}

class RemoteDataStore: APIDataStore {
    
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
    
    func getFuelPriceByTown(fuelIdentifier: String, townIdentifier: String, completionHandler: @escaping ([Consulta]?) -> ()) {
        var replacedString = APIUrls.urlBusquedaMunicipiosCarburantes.rawValue.replace(occurrences: ["{IDMUNICIPIO}" : townIdentifier])
        replacedString = replacedString.replace(occurrences: ["{IDPRODUCTO}" : fuelIdentifier])
        guard let url = URL(string: replacedString) else { return }
        let urlRequest = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            guard error == nil, let urlResponse = urlResponse as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            let queryDecode = try! jsonDecoder.decode([Consulta].self, from: data)
            completionHandler(queryDecode)
        }
        task.resume()
    }
}
