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
    @IBOutlet var gasStationInformationView: UIView!
    @IBOutlet var gasStationNameLabel: UILabel!
    @IBOutlet var favoriteIcon: UIImageView!
    @IBOutlet var gasStationFuelsView: UIView!
    @IBOutlet var fuelsCollectionView: UICollectionView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var openMapsButton: CustomButton!
    @IBOutlet var fuelsCollectionViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    var gasStation: PreciosGasolinera?
    var userLocation: CLLocation?
    var presenter: GasStationLocationPresenter?

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = GasStationLocationPresenter(self)
        setUpUI()
        setUpCollectionView()
        setUpLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewHeight()
    }
    
    //MARK: - Functions
    func setUpUI() {
        guard let gasStation = gasStation else {
            return
        }
        if gasStation.gasolinera.favorita {
            self.favoriteIcon.tintColor = Colors.yellow
        }
        else {
            self.favoriteIcon.tintColor = Colors.lightGray
        }
        self.backButton.setTitle("", for: .normal)
        self.backButton.tintColor = Colors.green
        
        self.gasStationInformationView.layer.cornerRadius = 6
        self.gasStationInformationView.backgroundColor = Colors.white
        self.gasStationInformationView.dropShadow()
        self.gasStationNameLabel.font = Fonts.montserratBoldx20
        self.gasStationNameLabel.text = gasStation.gasolinera.nombre.uppercased()
        self.gasStationNameLabel.textColor = Colors.darkGray
        
        self.gasStationFuelsView.layer.cornerRadius = 6
        self.gasStationFuelsView.backgroundColor = Colors.white
        self.gasStationFuelsView.dropShadow()
        
        let layout = LeftAlignedCollectionFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.fuelsCollectionView.setCollectionViewLayout(layout, animated: true)
        self.fuelsCollectionView.backgroundColor = .clear
        
        self.openMapsButton.style = .filled
        self.openMapsButton.titleText = NSLocalizedString("GO_TO_GAS_STATION_MAPS_BUTTON_TITLE", comment: "")
        
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
    
    func setUpCollectionView() {
        self.fuelsCollectionView.dataSource = self
        self.fuelsCollectionView.delegate = self
        
        self.fuelsCollectionView.register(UINib.init(nibName: "FuelPriceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "fuelPriceCellIdentifier")
    }
    
    func updateCollectionViewHeight() {
        guard let layout = fuelsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        fuelsCollectionViewHeightConstraint.constant = layout.collectionViewContentSize.height
    }
    
    @objc func addFav() {
        guard var gasStation = gasStation, let isLogged = presenter?.isUserLogged() else {
            return
        }
        if isLogged {
            if gasStation.gasolinera.favorita {
                presenter?.removeFavorite(gasStation: gasStation.gasolinera)
                gasStation.gasolinera.favorita = false
                self.favoriteIcon.tintColor = Colors.white
            }
            else {
                presenter?.saveFavorite(gasStation: gasStation.gasolinera)
                gasStation.gasolinera.favorita = true
                self.favoriteIcon.tintColor = Colors.yellow
            }
        } else {
            let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default)
            self.showAlert(title: NSLocalizedString("USER_NOT_LOGGED_TITLE", comment: ""), message: NSLocalizedString("USER_NOT_LOGGED_MESSAGE", comment: ""), alternativeAction: nil, acceptAction: acceptAction)
        }
    }
    
    func showRouteOnMap() {
//        guard let gasStationLocation = gasStation?.gasolinera.ubicacion else {
//            return
//        }
//        let destinationPlacemark = MKPlacemark(coordinate: gasStationLocation.coordinate, addressDictionary: nil)
//
//        let destinationAnnotation = MKPointAnnotation()
//
//        if let location = destinationPlacemark.location {
//            destinationAnnotation.coordinate = location.coordinate
//        }
//
//        self.mapView.showAnnotations([destinationAnnotation], animated: true )
        
        guard let gasStationLocation = gasStation?.gasolinera.ubicacion else {
            return
        }

        let destinationPlacemark = MKPlacemark(coordinate: gasStationLocation.coordinate, addressDictionary: nil)
        let destinationAnnotation = MKPointAnnotation()

        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }

        self.mapView.addAnnotation(destinationAnnotation)

        // Cálculo del espacio disponible en el mapa
        let topSafeAreaHeight = self.view.frame.minY
        let bottomViewTopY = gasStationInformationView.frame.minY
        let availableMapHeight = bottomViewTopY - topSafeAreaHeight
        let totalMapHeight = self.mapView.frame.height
        let offsetFactor = (totalMapHeight - availableMapHeight) / totalMapHeight

        // Crear una región ajustada para centrar la anotación en el área visible
        let region = MKCoordinateRegion(center: gasStationLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        let latitudeOffset = region.span.latitudeDelta * Double(offsetFactor)

        // Aplicar la región ajustada
        var adjustedRegion = region
        adjustedRegion.center.latitude -= latitudeOffset

        self.mapView.setRegion(adjustedRegion, animated: true)
    }
    
    //MARK: - IBActions
    @IBAction func goToGasStationButtonPressed(_ sender: Any) {
        let targetURL = URL(string: "http://maps.apple.com/?q=cupertino")!
        
        if UIApplication.shared.canOpenURL(targetURL) {
            UIApplication.shared.open(targetURL)
        }
    }
    
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

extension GasStationLocationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gasStation?.precios.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let gasStation else {
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fuelPriceCellIdentifier", for: indexPath) as! FuelPriceCollectionViewCell
        cell.setUpUI(fuelName: gasStation.precios[indexPath.row].carburante.nombreProductoAbreviatura, fuelPrice: gasStation.precios[indexPath.row].precio, fuelColor: UIColor(named: gasStation.precios[indexPath.row].carburante.nombreProductoAbreviatura) ?? .black)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
