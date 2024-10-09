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
    @IBOutlet var navigationBar: UINavigationBar!
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
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = Colors.white
        self.navigationBar.topItem?.title = ""
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(popToPrevious))
        barButtonItem.tintColor = Colors.green
        self.navigationBar.topItem?.leftBarButtonItem = barButtonItem
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resetMapZoom))
        self.gasStationsMapView.addGestureRecognizer(tapGesture)
        
        let nib = UINib(nibName: "GasStationsOnRouteTableViewCell", bundle: nil)
        self.gasStationsTableView.register(nib, forCellReuseIdentifier: "stationsOnRouteCellIdentifier")
    }
    
    func setDelegates() {
        viewModel.delegate = self
        gasStationsMapView.delegate = self
        gasStationsTableView.delegate = self
        gasStationsTableView.dataSource = self
    }
    
    func initConfiguration() {
        guard let fuel, let route else { return }
        self.gasStationsMapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
        self.gasStationsMapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
        self.viewModel.fetchGasStationsAlongRoute(route: route, fuel: fuel) { listaGasolineras in
            listaGasolineras.forEach { gasolinera in
                self.showPossibleGasStation(gasolinera: gasolinera)
            }
            self.posibleGasStations = listaGasolineras
            self.gasStationsTableView.reloadData()
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
    
    func showGasStationInfo(gasolinera: ListaEESSPrecio) {
        guard let latitud = Double(gasolinera.latitud.replacingOccurrences(of: ",", with: ".")), let longitud = Double(gasolinera.longitud.replacingOccurrences(of: ",", with: ".")) else {
            return
        }
        let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitud, longitude: longitud), latitudinalMeters: 500, longitudinalMeters: 500)
        self.gasStationsMapView.setRegion(zoomRegion, animated: true)
    }
    
    @objc func popToPrevious() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func resetMapZoom() {
        guard let route else { return }
        self.gasStationsMapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationsOnRouteCellIdentifier", for: indexPath) as! GasStationsOnRouteTableViewCell
        cell.setUpUI(gasStationName: posibleGasStations[indexPath.row].rotulo, gasStationLocation: posibleGasStations[indexPath.row].municipio, gasStationSchedule: posibleGasStations[indexPath.row].horario, fuelPrice: posibleGasStations[indexPath.row].precioProducto)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.showGasStationInfo(gasolinera: posibleGasStations[indexPath.row])
    }
}

extension GasStationsOnRouteViewController: GasStationsOnRouteViewModelDelegate {
    func showError() {
        self.showAlert(title: "", message: "Has realizado demasiadas peticiones en poco tiempo. Espera unos minutos y vuelve a intentarlo.", alternativeAction: nil, acceptAction: UIAlertAction(title: "Aceptar", style: .default))
    }
    
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
