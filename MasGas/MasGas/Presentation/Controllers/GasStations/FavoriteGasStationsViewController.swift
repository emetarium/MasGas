//
//  FavoriteGasStationsViewController.swift
//  MasGas
//
//  Created by María García Torres on 15/2/22.
//

import UIKit
import MapKit

protocol FavoriteGasStationsProtocol {
    func updateFavoritesList(favoriteGasStations: [Gasolinera])
    func showLoading()
    func hideLoading()
}

class FavoriteGasStationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var gasStationsTableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Variables
    var userLocation: CLLocation?
    var favoriteGasStations: [Gasolinera] = []
    var presenter: FavoriteGasStationsPresenter<FavoriteGasStationsViewController>?

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = FavoriteGasStationsPresenter(self)
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFavoriteGasStations()
    }
    
    //MARK: - Functions
    func setUpUI() {
        self.view.backgroundColor = Colors.white
        self.activityIndicator.color = Colors.green
        self.activityIndicator.isHidden = true
        mapView.pointOfInterestFilter = .some(MKPointOfInterestFilter(including: [MKPointOfInterestCategory.gasStation]))
        setUpUserLocation()
        registerCell()
        setUpTableView()
    }
    
    func getFavoriteGasStations() {
        presenter?.getFavorites()
    }
    
    func setUpUserLocation() {
        LocationLayer.shared.getCurrentLocation { location in
            guard let location = location else {
                return
            }
            self.userLocation = location
            self.mapView.centerToLocation(location)
        }
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
        cell.setUpUI(gasStationName: favoriteGasStations[indexPath.row].nombre)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GasStationLocationViewController") as? GasStationLocationViewController
        guard let vc = gvc else { return }
        vc.gasStation = favoriteGasStations[indexPath.row]
        LocationLayer.shared.getCurrentLocation { location in
            guard let location = location else {
                return
            }
            vc.userLocation = location
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension FavoriteGasStationsViewController: FavoriteGasStationsProtocol {
    func updateFavoritesList(favoriteGasStations: [Gasolinera]) {
        self.favoriteGasStations = favoriteGasStations
        DispatchQueue.main.async {
            self.gasStationsTableView.reloadData()
        }
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
