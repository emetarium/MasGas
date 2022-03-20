//
//  SearchFuelPresenter.swift
//  MasGas
//
//  Created by María García Torres on 2/3/22.
//

import Foundation
import CoreLocation

class SearchFuelPresenter<SearchFuelProtocol> {
    let view: SearchFuelViewController
    let searchFuelUseCase: SearchFuelUseCase?
    let isFavoriteUseCase: SearchFavoriteUseCase?
    
    init(_ view: SearchFuelViewController) {
        self.view = view
        self.searchFuelUseCase = SearchFuelUseCase()
        self.isFavoriteUseCase = SearchFavoriteUseCase()
    }
    
    func searchFuel(fuel: Carburante) {
        self.view.showLoading()
        searchFuelUseCase?.execute(fuelIdentifier: fuel.idProducto, completion: { priceList in
            if let priceList = priceList {
                DispatchQueue.main.async {
                    let fuelList = self.calculateDistance(gasStationInformation: priceList)
                    self.sortFuels(searchMode: .queryByCheapestNearby, fuelList: fuelList)
                }
            }
        })
    }
    
    func sortFuels(searchMode: queryByFuelOptions, fuelList: [BusquedaCarburante]) {
        var orderedList = fuelList
        switch searchMode {
            case .queryByNearby:
                orderedList.sort { $0.distancia < $1.distancia }
            case .queryByCheapest:
                orderedList.sort { $0.precioProducto < $1.precioProducto }
            case .queryByCheapestNearby:
                orderedList.sort { $0.precioProducto < $1.precioProducto &&  $0.distancia < $1.distancia }
        }
        self.view.hideLoading()
        self.view.updateFuelList(fuelList: orderedList)
    }
    
    func calculateDistance(gasStationInformation: [ListaEESSPrecio]) -> [BusquedaCarburante] {
        var fuelInformationList: [BusquedaCarburante] = []
        gasStationInformation.forEach { gasStation in
            let latitud = (gasStation.latitud.replacingOccurrences(of: ",", with: ".") as NSString).doubleValue
            let longitud = (gasStation.longitud.replacingOccurrences(of: ",", with: ".") as NSString).doubleValue
            let gasStationLocation: CLLocation = CLLocation(latitude: latitud, longitude: longitud)
            
            LocationLayer.shared.getCurrentLocation { location in
                guard let location = location, let distance = LocationLayer.shared.getDistanceBetweenLocations(userLocation: location, gasStationLocation: gasStationLocation) else { return }
                let fuelInformation = BusquedaCarburante(nombre: gasStation.rotulo, id: gasStation.idEESS, precioProducto: gasStation.precioProducto, horario: gasStation.horario, distancia: distance, coordenadas: gasStationLocation)
                fuelInformationList.append(fuelInformation)
            }
        }
        return fuelInformationList
    }
    
    func isFavorite(gasStation: BusquedaCarburante, completion: @escaping (Bool) -> ()) {
        isFavoriteUseCase?.execute(gasStationID: gasStation.id, completion: { result in
            completion(result)
        })
    }
}
