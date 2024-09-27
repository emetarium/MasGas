//
//  SearchFuelViewModel.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import CoreLocation

protocol SearchFuelViewModelDelegate {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func updateFuelList(fuelList: [BusquedaCarburante])
    func showNoLocationPermissionAlert()
}

class SearchFuelViewModel {
    
    var delegate: SearchFuelViewModelDelegate?
    
    func isUserLogged() -> Bool {
        if UserDefaults.standard.object(forKey: "User") != nil {
            return true
        }
        else {
            return false
        }
    }
    
    func searchFuel(fuel: Carburante) {
        self.delegate?.showLoadingIndicator()
        
        if IsLocationEnabledUseCase().execute() {
            SearchFuelUseCase().execute(fuelIdentifier: fuel.idProducto, completion: { priceList in
                self.delegate?.hideLoadingIndicator()
                if let priceList = priceList {
                    GetLocationUseCase().execute(completion: { location in
                        if let location {
                            self.calculateDistance(userLocation: location, gasStationInformation: priceList) { fuelList in
                                self.sortFuels(searchMode: .queryByCheapestNearby, fuelList: fuelList)
                            }
                        }
                    })
                }
            })
        } else {
            self.delegate?.hideLoadingIndicator()
            self.delegate?.showNoLocationPermissionAlert()
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
        self.delegate?.updateFuelList(fuelList: orderedList)
    }
    
    func calculateDistance(userLocation: CLLocation, gasStationInformation: [ListaEESSPrecio], completion: ([BusquedaCarburante]) -> ()) {
        var fuelInformationList: [BusquedaCarburante] = []
        gasStationInformation.forEach { gasStation in
            let latitud = (gasStation.latitud.replacingOccurrences(of: ",", with: ".") as NSString).doubleValue
            let longitud = (gasStation.longitud.replacingOccurrences(of: ",", with: ".") as NSString).doubleValue
            let gasStationLocation = CLLocation(latitude: latitud, longitude: longitud)
            
            CalculateDistanceBetweenLocationsUseCase().execute(userLocation: userLocation, gasStation: gasStationLocation, completion: { distance in
                let fuelInformation = BusquedaCarburante(nombre: gasStation.rotulo, id: gasStation.idEESS, precioProducto: gasStation.precioProducto, horario: gasStation.horario, distancia: distance, coordenadas: gasStationLocation, direccion: gasStation.direccion, municipio: gasStation.municipio)
                fuelInformationList.append(fuelInformation)
            })
        }
        completion(fuelInformationList)
    }
    
    func isFavorite(gasStation: BusquedaCarburante, completion: @escaping (Bool) -> ()) {
        SearchFavoriteUseCase().execute(gasStationID: gasStation.id, completion: { result in
            completion(result)
        })
    }
}
