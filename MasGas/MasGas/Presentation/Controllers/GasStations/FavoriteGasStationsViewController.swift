//
//  FavoriteGasStationsViewController.swift
//  MasGas
//
//  Created by María García Torres on 15/2/22.
//

import UIKit
import MapKit

protocol FavoriteGasStationsProtocol {
    func updateFavoritesList(favoriteGasStations: [PreciosGasolinera])
    func setUpMap(location: CLLocation)
    func showNoConnectionAlert()
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

class FavoriteGasStationsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var gasStationsTableView: UITableView!
    @IBOutlet var emptyListView: UIView!
    @IBOutlet var emptyListLabel: UILabel!
    
    //MARK: - Variables
    var userLocation: CLLocation?
    var favoriteGasStations: [PreciosGasolinera] = []
    var viewModel = FavoriteGasStationsViewModel()

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        setDelegates()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFavoriteGasStations()
    }
    
    //MARK: - Functions
    func setUpUI() {
        self.view.backgroundColor = Colors.white
        self.emptyListView.backgroundColor = Colors.clear
        self.emptyListLabel.font = Fonts.montserratx12
        self.emptyListLabel.text = NSLocalizedString("EMPTY_LIST_MESSAGE", comment: "")
        setUpLocation()
        registerCell()
        setUpTableView()
    }
    
    func setDelegates() {
        viewModel.delegate = self
    }
    
    func getFavoriteGasStations() {
        if viewModel.isUserLogged() {
            viewModel.getFavorites()
        }
    }
    
    func setUpLocation() {
        viewModel.setUpMap()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: "GasStationTableViewCell", bundle: nil)
        self.gasStationsTableView.register(nib, forCellReuseIdentifier: "gasStationCell")
    }
    
    private func setUpTableView() {
        self.gasStationsTableView.delegate = self
        self.gasStationsTableView.dataSource = self
        self.gasStationsTableView.separatorStyle = .none
        self.gasStationsTableView.backgroundColor = Colors.lightGray
    }

    //MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteGasStations.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("FAVORITE_GAS_STATIONS_TITLE", comment: "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = gasStationsTableView.dequeueReusableCell(withIdentifier: "gasStationCell", for: indexPath) as! GasStationTableViewCell
        cell.setUpUI(gasStationName: favoriteGasStations[indexPath.row].gasolinera.nombre, gasStationAddress: favoriteGasStations[indexPath.row].gasolinera.direccion, gasStationTown: favoriteGasStations[indexPath.row].gasolinera.municipio)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GasStationLocationViewController") as? GasStationLocationViewController
        guard let vc = gvc else { return }
        vc.gasStation = favoriteGasStations[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            viewModel.removeFavorite(gasStation: favoriteGasStations[indexPath.row].gasolinera)
            favoriteGasStations.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension FavoriteGasStationsViewController: FavoriteGasStationsViewModelDelegate {
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
    
    func showNoConnectionAlert() {
        let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default) { action in
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }
        self.showAlert(title: NSLocalizedString("NO_CONNECTION_ERROR_TITLE", comment: ""), message: NSLocalizedString("NO_CONNECTION_ERROR_MESSAGE", comment: ""), alternativeAction: nil, acceptAction: acceptAction)
    }
    
    func setUpMap(location: CLLocation) {
        self.userLocation = location
        self.mapView.centerToLocation(location)
        self.mapView.showsUserLocation = true
    }
    
    func updateFavoritesList(favoriteGasStations: [PreciosGasolinera]) {
        self.favoriteGasStations = favoriteGasStations
        DispatchQueue.main.async {
            self.gasStationsTableView.reloadData()
            if favoriteGasStations.isEmpty {
                self.emptyListView.isHidden = false
                self.emptyListLabel.text = NSLocalizedString("EMPTY_LIST_MESSAGE", comment: "")
                self.mapView.showAnnotations([], animated: true)
            } else {
                self.emptyListView.isHidden = true
                var favoriteGasStationsAnnotations: [MKPointAnnotation] = []
                
                favoriteGasStations.forEach { gasStation in
                    let gasStationPlacemark = MKPlacemark(coordinate: gasStation.gasolinera.ubicacion.coordinate, addressDictionary: nil)
                    let gasStationAnnotation = MKPointAnnotation()
                    if let location = gasStationPlacemark.location {
                        gasStationAnnotation.coordinate = location.coordinate
                    }
                    favoriteGasStationsAnnotations.append(gasStationAnnotation)
                }

                self.mapView.showAnnotations(favoriteGasStationsAnnotations, animated: true)
            }
        }
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
