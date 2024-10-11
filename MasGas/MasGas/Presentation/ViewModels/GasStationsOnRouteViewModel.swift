//
//  GasStationsOnRouteViewModel.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import MapKit

protocol GasStationsOnRouteViewModelDelegate {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showError()
}

class GasStationsOnRouteViewModel {
    
    var delegate: GasStationsOnRouteViewModelDelegate?
    
    func fetchGasStationsAlongRoute(route: MKRoute, fuel: Carburante, completion: @escaping ([ListaEESSPrecio]) -> Void) {
        self.delegate?.showLoadingIndicator()
        getMunicipalitiesFromKeyPoints(route: route) { municipios in
            var municipalities: [Municipio] = []
            var posibleGasStations: [ListaEESSPrecio] = []
            
            // Crear un DispatchGroup
            let dispatchGroup = DispatchGroup()
            
            FetchTownsUseCase().execute { towns in
                for town in towns {
                    if municipios.contains(town.nombreMunicipio.formatName()) {
                        municipalities.append(town)
                        
                        // Entrar en el DispatchGroup antes de hacer la llamada asincrónica
                        dispatchGroup.enter()
                        
                        self.getGasStationsOnMunicipality(municipality: town, fuel: fuel) { listaPrecios in
                            self.getClosestCheapestGasStation(listaPrecios: listaPrecios, route: route) { gasStation in
                                if let gasStation = gasStation {
                                    posibleGasStations.append(gasStation)
                                }
                                
                                // Marcar la tarea como completada al finalizar la llamada
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                
                // Esperar a que todas las tareas en el DispatchGroup se completen
                dispatchGroup.notify(queue: .main) {
                    self.delegate?.hideLoadingIndicator()
                    posibleGasStations.sort { $0.precioProducto < $1.precioProducto }
                    completion(posibleGasStations)
                }
            }
        }
    }

    
    func getGasStationsOnMunicipality(municipality: Municipio, fuel: Carburante, completion: @escaping (([ListaEESSPrecio]) -> Void)) {
        SearchFuelByTownUseCase().execute(townIdentifier: municipality.idMunicipio, fuelIdentifier: fuel.idProducto) { listaPrecios in
            completion(listaPrecios ?? [])
        }
    }
    
    func getClosestCheapestGasStation(listaPrecios: [ListaEESSPrecio], route: MKRoute, completion: @escaping ((ListaEESSPrecio?) -> Void)) {
        var cheapestGasStation: ListaEESSPrecio?
        listaPrecios.forEach { gasStation in
            guard let latitud = Double(gasStation.latitud.replacingOccurrences(of: ",", with: ".")), let longitud = Double(gasStation.longitud.replacingOccurrences(of: ",", with: ".")) else { return }
            let gasStationLocation = CLLocation(latitude: latitud, longitude: longitud)
                    
            for step in route.steps {
                let routeLocation = CLLocation(latitude: step.polyline.coordinate.latitude, longitude: step.polyline.coordinate.longitude)
                
                let distance = gasStationLocation.distance(from: routeLocation)
                
                // Si la estación está dentro del rango permitido, evalúa el precio
                if distance < 5000 {
                    if cheapestGasStation == nil || gasStation.precioProducto < cheapestGasStation!.precioProducto {
                        cheapestGasStation = gasStation
                    }
                }
            }
        }
        completion(cheapestGasStation)
    }
    
    func getGasStationsOnRoute(municipalities: [Municipio], fuel: Carburante, completion: @escaping (([ListaEESSPrecio]) -> Void)) {
        municipalities.forEach { municipality in
            SearchFuelByTownUseCase().execute(townIdentifier: municipality.idMunicipio, fuelIdentifier: fuel.idProducto) { listaPrecios in
                completion(listaPrecios ?? [])
            }
        }
    }
    
    func getMunicipalitiesFromKeyPoints(route: MKRoute, completion: @escaping ([String]) -> Void) {
        let keyPoints = getKeyPointsFromRouteByDistance(route: route)
        var municipalities: [String] = []
        let maxRequestsPerMinute = 50
        let intervalBetweenRequests: TimeInterval = 60.0 / Double(maxRequestsPerMinute)
        let group = DispatchGroup()
        
        // Cola para manejar las solicitudes de geocodificación
        var requestQueue: [CLLocation] = keyPoints.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        var stopProcessing = false
        
        // Función para manejar el proceso de cada solicitud de geocodificación
        func processNextLocation() {
            guard !requestQueue.isEmpty, !stopProcessing else {
                // Cuando se hayan procesado todas las solicitudes
                group.notify(queue: .main) {
                    completion(municipalities)
                }
                return
            }
            
            // Obtener la siguiente ubicación
            let location = requestQueue.removeFirst()
            group.enter()
            
            // Solicitar la geocodificación
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first {
                    if let country = placemark.isoCountryCode, country == "ES" {
                        if let municipality = placemark.locality, !municipalities.contains(municipality) {
                            municipalities.append(municipality)
                        }
                    } else {
                        stopProcessing = true
                        requestQueue.removeAll() // Vaciamos la cola para no procesar más ubicaciones
                    }
                }
                if let _ = error {
                    self.delegate?.showError()
                }
                group.leave()
                
                // Después de procesar esta solicitud, hacer la siguiente tras un intervalo
                DispatchQueue.main.asyncAfter(deadline: .now() + intervalBetweenRequests) {
                    processNextLocation()
                }
            }
        }
        
        // Iniciar el procesamiento de la primera ubicación
        processNextLocation()
    }

    // Función auxiliar para obtener los puntos clave de la ruta
    func getKeyPointsFromRouteByDistance(route: MKRoute, distanceInterval: CLLocationDistance = 7000) -> [CLLocationCoordinate2D] {
        var keyPoints: [CLLocationCoordinate2D] = []
        var accumulatedDistance: CLLocationDistance = 0
        var lastAddedPointDistance: CLLocationDistance = 0
        
        // Añadir el primer punto de la ruta
        if let startPoint = route.steps.first?.polyline.coordinate {
            keyPoints.append(startPoint)
        }
        
        for step in route.steps {
            let stepPoints = step.polyline.points()
            
            for i in 0..<step.polyline.pointCount {
                let coordinate = stepPoints[i].coordinate
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                
                // Si hay más de un punto, calcular la distancia entre este y el anterior
                if i > 0 {
                    let previousCoordinate = stepPoints[i - 1].coordinate
                    let previousLocation = CLLocation(latitude: previousCoordinate.latitude, longitude: previousCoordinate.longitude)
                    let distanceBetweenPoints = location.distance(from: previousLocation)
                    
                    accumulatedDistance += distanceBetweenPoints
                }
                    
                // Añadir un punto clave cada vez que la distancia acumulada exceda el intervalo especificado
                if accumulatedDistance - lastAddedPointDistance >= distanceInterval {
                    keyPoints.append(coordinate)
                    lastAddedPointDistance = accumulatedDistance
                }
            }
        }
        
        // Añadir el último punto de la ruta
        if let endPoint = route.steps.last?.polyline.coordinate {
            keyPoints.append(endPoint)
        }
        
        return keyPoints
    }
}
