//
//  SearchFuelPresenter.swift
//  MasGas
//
//  Created by María García Torres on 2/3/22.
//

import Foundation
import UIKit
import CoreLocation

class SearchFuelPresenter<SearchFuelProtocol>: BasePresenter {
    let view: SearchFuelViewController
    let searchFuelUseCase: SearchFuelUseCase?
    let isFavoriteUseCase: SearchFavoriteUseCase?
    let isLocationEnabledUseCase: IsLocationEnabledUseCase?
    let getLocationUseCase: GetLocationUseCase?
    let calculateDistanceUseCase: CalculateDistanceBetweenLocationsUseCase?
    
    init(_ view: SearchFuelViewController) {
        self.view = view
        self.searchFuelUseCase = SearchFuelUseCase()
        self.isFavoriteUseCase = SearchFavoriteUseCase()
        self.isLocationEnabledUseCase = IsLocationEnabledUseCase()
        self.getLocationUseCase = GetLocationUseCase()
        self.calculateDistanceUseCase = CalculateDistanceBetweenLocationsUseCase()
    }
    
    func searchFuel(fuel: Carburante) {
        self.view.showLoadingIndicator()
        
        guard let isLocationEnabled = isLocationEnabledUseCase?.execute() else { return }
        if isLocationEnabled {
            searchFuelUseCase?.execute(fuelIdentifier: fuel.idProducto, completion: { priceList in
                self.view.hideLoadingIndicator()
                if let priceList = priceList {
                    self.getLocationUseCase?.execute(completion: { location in
                        if let location = location {
                            self.calculateDistance(userLocation: location, gasStationInformation: priceList) { fuelList in
                                self.sortFuels(searchMode: .queryByCheapestNearby, fuelList: fuelList)
                            }
                        }
                    })
                }
            })
        } else {
            self.view.hideLoadingIndicator()
            self.view.showNoLocationPermissionAlert()
        }
    }
    
    func sortFuels(searchMode: queryByFuelOptions, fuelList: [BusquedaCarburante]) {
        var orderedList = fuelList
        switch searchMode {
            case .queryByNearby:
                orderedList.sort { $0.distancia < $1.distancia }
            case .queryByCheapest:
                orderedList.sort { $0.precioProducto < $1.precioProducto }
            case .queryByCheapestNearby:
                orderedList.sort { $0.distancia == $1.distancia ? $0.precioProducto < $1.precioProducto : $0.distancia < $1.distancia }
        }
        self.view.updateFuelList(fuelList: orderedList)
    }
    
    func calculateDistance(userLocation: CLLocation, gasStationInformation: [ListaEESSPrecio], completion: ([BusquedaCarburante]) -> ()) {
        var fuelInformationList: [BusquedaCarburante] = []
        gasStationInformation.forEach { gasStation in
            let latitud = (gasStation.latitud.replacingOccurrences(of: ",", with: ".") as NSString).doubleValue
            let longitud = (gasStation.longitud.replacingOccurrences(of: ",", with: ".") as NSString).doubleValue
            let gasStationLocation = CLLocation(latitude: latitud, longitude: longitud)
            
            self.calculateDistanceUseCase?.execute(userLocation: userLocation, gasStation: gasStationLocation, completion: { distance in
                let fuelInformation = BusquedaCarburante(nombre: gasStation.rotulo, id: gasStation.idEESS, precioProducto: gasStation.precioProducto, horario: gasStation.horario, distancia: distance, coordenadas: gasStationLocation)
                fuelInformationList.append(fuelInformation)
            })
        }
        completion(fuelInformationList)
    }
    
    func isFavorite(gasStation: BusquedaCarburante, completion: @escaping (Bool) -> ()) {
        isFavoriteUseCase?.execute(gasStationID: gasStation.id, completion: { result in
            completion(result)
        })
    }
    
    func checkInternetConnection() {
        if !isInternetAvailable() {
            self.view.showNoConnectionAlert()
        }
    }
}
