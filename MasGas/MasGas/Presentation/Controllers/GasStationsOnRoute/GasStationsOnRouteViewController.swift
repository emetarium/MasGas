//
//  GasStationsOnRouteViewController.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import UIKit
import MapKit

class GasStationsOnRouteViewController: BaseViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var gasStationsMapView: MKMapView!
    @IBOutlet var gasStationsTableView: UITableView!
    @IBOutlet var gasStationsTableViewHeight: NSLayoutConstraint!
    
    // MARK: - Vars
    var originLocation: MKPointAnnotation?
    var destinationLocation: MKPointAnnotation?
    var fuel: Carburante?
    var route: MKRoute?
    let viewModel = GasStationsOnRouteViewModel()
    var posibleGasStations: [ListaEESSPrecio] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        setDelegates()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initConfiguration()
    }
    
    func setUpUI() {
        
    }
    
    func setDelegates() {
        viewModel.delegate = self
        gasStationsMapView.delegate = self
        gasStationsTableView.delegate = self
        gasStationsTableView.dataSource = self
    }
    
    func initConfiguration() {
        guard let fuel else { return }
        calculateRoute { route in
            self.viewModel.fetchGasStationsAlongRoute(route: route, fuel: fuel) { listaGasolineras in
                listaGasolineras.forEach { gasolinera in
                    self.showPossibleGasStation(gasolinera: gasolinera)
                }
                print(listaGasolineras.count)
                self.posibleGasStations = listaGasolineras
                self.gasStationsTableView.reloadData()
            }
        }
    }
    
    func calculateRoute(completion: @escaping (MKRoute) -> Void) {
        guard let originLocation, let destinationLocation else { return }
        let originPlacemark = MKPlacemark(coordinate: originLocation.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation.coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: originPlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error {
                print("Error al calcular ruta \(error)")
            }
            
            guard var sortedRoutes = response?.routes else { return }
            sortedRoutes.sort { $0.expectedTravelTime < $1.expectedTravelTime }
            
            guard let route = sortedRoutes.first else { return }
            
            self.gasStationsMapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            self.gasStationsMapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)

            completion(route)
        }
    }
    
    func showPossibleGasStation(gasolinera: ListaEESSPrecio) {
        guard let latitud = Double(gasolinera.latitud.replacingOccurrences(of: ",", with: ".")), let longitud = Double(gasolinera.longitud.replacingOccurrences(of: ",", with: ".")) else {
            return
        }
        
        let gasStationLocation = CLLocation(latitude: latitud, longitude: longitud)

        let destinationPlacemark = MKPlacemark(coordinate: gasStationLocation.coordinate, addressDictionary: nil)
        let destinationAnnotation = MKPointAnnotation()

        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
            destinationAnnotation.title = gasolinera.precioProducto + "€"
        }

        self.gasStationsMapView.addAnnotation(destinationAnnotation)
    }
}

extension GasStationsOnRouteViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 5.0
        return renderer
    }
}

extension GasStationsOnRouteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posibleGasStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension GasStationsOnRouteViewController: GasStationsOnRouteViewModelDelegate {
    func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.showLoading()
        }
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.hideLoading()
        }
    }
}
