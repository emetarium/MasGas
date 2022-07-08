//
//  GasStationLocationViewController.swift
//  MasGas
//
//  Created by María García Torres on 7/3/22.
//

import UIKit
import MapKit

protocol UpdateLocationProtocol {
    func updateLocation(location: CLLocation)
    func showNoConnectionAlert()
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

class GasStationLocationViewController: BaseViewController, MKMapViewDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var favoriteIcon: UIImageView!
    @IBOutlet var backButton: UIButton!
    
    //MARK: - Variables
    var gasStation: Gasolinera?
    var userLocation: CLLocation?
    var presenter: GasStationLocationPresenter?

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = GasStationLocationPresenter(self)
        setUpUI()
        setUpLocation()
    }
    
    //MARK: - Functions
    func setUpUI() {
        guard let gasStation = gasStation, let yellow = Colors.yellow else {
            return
        }
        if gasStation.favorita {
            self.favoriteIcon.tintColor = yellow
        }
        else {
            self.favoriteIcon.tintColor = Colors.white
        }
        self.backButton.setTitle("", for: .normal)
        self.backButton.tintColor = Colors.green
        
        setUpMap()
        setUpTapGesture()
        presenter?.checkInternetConnection()
    }
    
    func setUpTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addFav))
        self.favoriteIcon.isUserInteractionEnabled = true
        self.favoriteIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUpMap() {
        mapView.delegate = self
    }
    
    func setUpLocation() {
        presenter?.getLocation()
    }
    
    @objc func addFav() {
        guard var gasStation = gasStation, let yellow = Colors.yellow else {
            return
        }
        if gasStation.favorita {
            presenter?.removeFavorite(gasStation: gasStation)
            gasStation.favorita = false
            self.favoriteIcon.tintColor = Colors.white
        }
        else {
            presenter?.saveFavorite(gasStation: gasStation)
            gasStation.favorita = true
            self.favoriteIcon.tintColor = yellow
        }
    }
    
    func showRouteOnMap() {
        guard let userLocation = userLocation, let gasStationLocation = gasStation?.ubicacion else {
            return
        }
        let sourcePlacemark = MKPlacemark(coordinate: userLocation.coordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: gasStationLocation.coordinate, addressDictionary: nil)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let sourceAnnotation = MKPointAnnotation()

        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }

        let destinationAnnotation = MKPointAnnotation()

        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }

        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )

        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile

        // Calculate the direction
        let directions = MKDirections(request: directionRequest)

        directions.calculate {
            (response, error) -> Void in

            guard let response = response else {
                if let _ = error {
                    let accept = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default) { action in
                        self.mapView.centerToLocation(gasStationLocation)
                    }
                    self.showAlert(title: NSLocalizedString("NO_ROUTE_ERROR_TITLE", comment: ""), message: NSLocalizedString("NO_ROUTE_ERROR_MESSAGE", comment: ""), alternativeAction: nil, acceptAction: accept)
                }
                return
            }

            let route = response.routes[0]

            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)

            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    //MARK: - IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let renderer = MKPolylineRenderer(overlay: overlay)

        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)

        renderer.lineWidth = 5.0

        return renderer
    }

}

extension GasStationLocationViewController: UpdateLocationProtocol {
    func updateLocation(location: CLLocation) {
        self.userLocation = location
        DispatchQueue.main.async {
            self.showRouteOnMap()
        }
    }
    
    func showNoConnectionAlert() {
        let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default) { action in
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }
        self.showAlert(title: NSLocalizedString("NO_CONNECTION_ERROR_TITLE", comment: ""), message: NSLocalizedString("NO_CONNECTION_ERROR_MESSAGE", comment: ""), alternativeAction: nil, acceptAction: acceptAction)
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

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
