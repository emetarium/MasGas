//
//  RemoteDataStore.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import Foundation

class RemoteDataStore {
    static let shared = RemoteDataStore()
    
    private init() {}
    
    func getTownsData(completionHandler: @escaping ([Municipio]?) -> ()) {
        var towns: [Municipio] = []
        guard let url = URL(string: APIUrls.urlMunicipios.rawValue) else { return }
        let urlRequest = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            guard error == nil, let urlResponse = urlResponse as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else { return }
            
            do {
                let jsonDecoder = JSONDecoder()
                let townDecode = try jsonDecoder.decode(Municipio.self, from: data)
                print(townDecode)
                towns.append(townDecode)
            } catch {
                completionHandler(nil)
            }
            completionHandler(towns)
        }
        task.resume()
    }
}
