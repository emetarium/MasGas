//
//  RouteViewController.swift
//  MasGas
//
//  Created by María García Torres on 24/9/24.
//

import UIKit
import CoreLocation
import MapKit

class RouteViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var locationsView: UIView!
    @IBOutlet var originLabel: UILabel!
    @IBOutlet var originTextField: UITextField!
    @IBOutlet var originSuggestionsTableView: UITableView!
    @IBOutlet var switchLocationsImageView: UIImageView!
    @IBOutlet var destinationLabel: UILabel!
    @IBOutlet var destinationTextField: UITextField!
    @IBOutlet var destinationSuggestionsTableView: UITableView!
    @IBOutlet var fuelsSelectionTextField: UITextField!
    @IBOutlet var fuelsTableView: UITableView!
    @IBOutlet var getGasStationsOnRouteButton: CustomButton!
    @IBOutlet var locationsMapView: MKMapView!
    
    @IBOutlet var originSuggestionsTableViewHeight: NSLayoutConstraint!
    @IBOutlet var destinationSuggestionsTableViewHeight: NSLayoutConstraint!
    @IBOutlet var fuelsTableViewHeight: NSLayoutConstraint!
    
    // MARK: - Vars
    let viewModel = RouteViewModel()
    
    var autoCompleteSearch = AutoCompleteSearch()
    var originSuggestions: [MKLocalSearchCompletion] = []
    var destinationSuggestions: [MKLocalSearchCompletion] = []
    var selectedOrigin: MKPointAnnotation? {
        didSet {
            if let selectedDestination {
                calculateRoute()
            }
        }
    }
    var selectedDestination: MKPointAnnotation? {
        didSet {
            if let selectedOrigin {
                calculateRoute()
            }
        }
    }
    var selectedRoute: MKRoute?
    var allRoutes: [MKRoute] = []
    var polylineToRouteMap: [MKPolyline: MKRoute] = [:]
    var selectedFuel: Carburante? {
        didSet {
            enableButton()
        }
    }
    var fuels: [Carburante] = []
    var isFuelsTableViewHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        setDelegates()
        initConfiguration()
        // Do any additional setup after loading the view.
    }
    
    func setUpUI() {
        self.locationsView.backgroundColor = Colors.white
        
        self.originLabel.font = Fonts.montserratx13
        self.originLabel.textColor = Colors.black
        self.originLabel.text = NSLocalizedString("ROUTE_ORIGIN_TEXT_FIELD_TITLE", comment: "")
        
        self.originTextField.clearButtonMode = .whileEditing
        
        self.switchLocationsImageView.image = UIImage(named: "switchIcon")
        self.switchLocationsImageView.isUserInteractionEnabled = true
        let switchGesture = UITapGestureRecognizer(target: self, action: #selector(switchLocations))
        self.switchLocationsImageView.addGestureRecognizer(switchGesture)
        
        self.destinationLabel.font = Fonts.montserratx13
        self.destinationLabel.textColor = Colors.black
        self.destinationLabel.text = NSLocalizedString("ROUTE_DESTINATION_TEXT_FIELD_TITLE", comment: "")
        
        self.destinationTextField.clearButtonMode = .whileEditing
        
        self.getGasStationsOnRouteButton.style = .filledDisabled
        self.getGasStationsOnRouteButton.setTitle(NSLocalizedString("ROUTE_SEARCH_GAS_STATIONS_BUTTON_TITLE", comment: ""), for: .normal)
        
        self.originSuggestionsTableView.dropShadow()
        self.originSuggestionsTableView.isHidden = true
        self.originSuggestionsTableView.roundCorners(corners: [.layerMinXMaxYCorner, . layerMaxXMaxYCorner], radius: 4)
        
        self.destinationSuggestionsTableView.dropShadow()
        self.destinationSuggestionsTableView.isHidden = true
        self.destinationSuggestionsTableView.roundCorners(corners: [.layerMinXMaxYCorner, . layerMaxXMaxYCorner], radius: 4)
        
        guard let dropdownImage = UIImage(named: "downArrow") else { return }
        self.fuelsSelectionTextField.setRightIcon(dropdownImage, color: Colors.green)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openFuelsDropdownMenu))
        self.fuelsSelectionTextField.isUserInteractionEnabled = true
        self.fuelsSelectionTextField.addGestureRecognizer(tapGesture)
        
        let routeTapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        self.locationsMapView.isUserInteractionEnabled = true
        self.locationsMapView.addGestureRecognizer(routeTapGesture)
    }
    
    func setDelegates() {
        self.viewModel.delegate = self
        
        self.originTextField.delegate = self
        self.destinationTextField.delegate = self
        
        self.originSuggestionsTableView.delegate = self
        self.originSuggestionsTableView.dataSource = self
        
        self.destinationSuggestionsTableView.delegate = self
        self.destinationSuggestionsTableView.dataSource = self
        
        self.fuelsTableView.delegate = self
        self.fuelsTableView.dataSource = self
        
        self.locationsMapView.delegate = self
    }
    
    func initConfiguration() {
        self.viewModel.getFuels()
        
        self.setGestureHideKeyboard()
        
        let nib = UINib(nibName: "LocationSuggestionTableViewCell", bundle: nil)
        self.originSuggestionsTableView.register(nib, forCellReuseIdentifier: "suggestionCellIdentifier")
        self.destinationSuggestionsTableView.register(nib, forCellReuseIdentifier: "suggestionCellIdentifier")
        
        let fuelNib = UINib(nibName: "FuelTableViewCell", bundle: nil)
        self.fuelsTableView.register(fuelNib, forCellReuseIdentifier: "fuelTableViewCell")
        
        autoCompleteSearch.updateHandler = { [weak self] in
            guard let self else { return }
            if self.originTextField.isFirstResponder {
                self.originSuggestions = self.autoCompleteSearch.results
                originSuggestionsTableView.reloadData()
                calculateTableViewHeight(tableView: originSuggestionsTableView)
            } else if self.destinationTextField.isFirstResponder {
                self.destinationSuggestions = self.autoCompleteSearch.results
                destinationSuggestionsTableView.reloadData()
                calculateTableViewHeight(tableView: destinationSuggestionsTableView)
            }
        }
    }
    
    func calculateTableViewHeight(tableView: UITableView) {
        let maxHeight = self.view.frame.height * 0.5
        let totalHeight = tableView.contentSize.height
            
        if totalHeight > maxHeight {
            if tableView == originSuggestionsTableView {
                originSuggestionsTableViewHeight.constant = maxHeight
            } else {
                destinationSuggestionsTableViewHeight.constant = maxHeight
            }
        } else {
            if tableView == originSuggestionsTableView {
                originSuggestionsTableViewHeight.constant = totalHeight
            } else {
                destinationSuggestionsTableViewHeight.constant = totalHeight
            }
        }
    }
    
    func markOriginOnMap(suggestion: MKLocalSearchCompletion) {
        if let selectedOrigin {
            self.locationsMapView.removeAnnotation(selectedOrigin)
        }
        
        let searchRequest = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, error) in
            guard let response = response, let mapItem = response.mapItems.first, error == nil else { return }
            
            let coordinate = mapItem.placemark.coordinate
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            self.selectedOrigin = annotation
            
            self.locationsMapView.addAnnotation(annotation)
            self.locationsMapView.showAnnotations(self.locationsMapView.annotations, animated: true)
        }
    }
    
    func markDestinationOnMap(suggestion: MKLocalSearchCompletion) {
        if let selectedDestination {
            self.locationsMapView.removeAnnotation(selectedDestination)
        }
        
        let searchRequest = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, error) in
            guard let response = response, let mapItem = response.mapItems.first, error == nil else {                 return }
            
            let coordinate = mapItem.placemark.coordinate
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            self.selectedDestination = annotation
            
            self.locationsMapView.addAnnotation(annotation)
            self.locationsMapView.showAnnotations(self.locationsMapView.annotations, animated: true)
        }
    }
    
    func calculateRoute() {
        guard let selectedOrigin, let selectedDestination else { return }
        
        self.locationsMapView.overlays.forEach { self.locationsMapView.removeOverlay($0) }
        self.allRoutes = []
        self.selectedRoute = nil
        
        let originPlacemark = MKPlacemark(coordinate: selectedOrigin.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: selectedDestination.coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: originPlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error {
                self.showAlert(title: NSLocalizedString("NO_ROUTE_ERROR_TITLE", comment: ""), message: NSLocalizedString("NO_ROUTE_ERROR_MESSAGE", comment: ""), alternativeAction: nil, acceptAction: UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default))
            }
            
            guard var sortedRoutes = response?.routes else { return }
            sortedRoutes.sort { $0.expectedTravelTime < $1.expectedTravelTime }
            
            self.allRoutes = sortedRoutes
            self.selectedRoute = sortedRoutes[0]
            self.enableButton()
            
            sortedRoutes.forEach { route in
                self.locationsMapView.addOverlay(route.polyline)
                self.polylineToRouteMap[route.polyline] = route
            }
            
            if let firstRoute = sortedRoutes.first {
                self.locationsMapView.setVisibleMapRect(firstRoute.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
            }
        }
    }
    
    func setGestureHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.locationsView.addGestureRecognizer(tap)
    }
    
    func enableButton() {
        guard let selectedOrigin, let selectedDestination, let selectedFuel, let selectedRoute else { return }
        self.getGasStationsOnRouteButton.style = .filled
    }
    
    private func distanceOf(pt: MKMapPoint, toPoly poly: MKPolyline) -> Double {
        var distance: Double = Double(MAXFLOAT)
        for n in 0..<poly.pointCount - 1 {
            let ptA = poly.points()[n]
            let ptB = poly.points()[n + 1]
            let xDelta: Double = ptB.x - ptA.x
            let yDelta: Double = ptB.y - ptA.y
            if xDelta == 0.0 && yDelta == 0.0 {
                // Points must not be equal
                continue
            }
            let u: Double = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            var ptClosest: MKMapPoint
            if u < 0.0 {
                ptClosest = ptA
            }
            else if u > 1.0 {
                ptClosest = ptB
            }
            else {
                ptClosest = MKMapPoint(x: ptA.x + u * xDelta, y: ptA.y + u * yDelta)
            }

            distance = min(distance, ptClosest.distance(to: pt))
        }
        return distance
    }

    private func meters(fromPixel px: Int, at pt: CGPoint) -> Double {
        let ptB = CGPoint(x: pt.x + CGFloat(px), y: pt.y)
        let coordA: CLLocationCoordinate2D = locationsMapView.convert(pt, toCoordinateFrom: locationsMapView)
        let coordB: CLLocationCoordinate2D = locationsMapView.convert(ptB, toCoordinateFrom: locationsMapView)
        return MKMapPoint(coordA).distance(to: MKMapPoint(coordB))
    }
    
    @objc func switchLocations() {
        guard let origin = originTextField.text, origin != "", let destination = destinationTextField.text, destination != "" else { return }
        
        originTextField.text = destination
        destinationTextField.text = origin
        
        let savedOrigin = selectedOrigin
        selectedOrigin = selectedDestination
        selectedDestination = savedOrigin
        
        self.calculateRoute()
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func openFuelsDropdownMenu() {
        fuelsTableView.isHidden = !fuelsTableView.isHidden
        guard let downImage = UIImage(named: "downArrow"), let upImage = UIImage(named: "upArrow") else { return }
        if fuelsTableView.isHidden {
            self.fuelsTableViewHeight.constant = 0
            self.fuelsSelectionTextField.setRightIcon(downImage, color: Colors.green)
        } else {
            self.fuelsTableViewHeight.constant = fuelsTableView.contentSize.height
            self.fuelsSelectionTextField.setRightIcon(upImage, color: Colors.green)
        }
        self.view.layoutIfNeeded()
    }
    
    @objc func mapTapped(_ tap: UITapGestureRecognizer) {
        self.view.endEditing(true)
        if tap.state == .recognized {
            let touchPt: CGPoint = tap.location(in: locationsMapView)
            let coord: CLLocationCoordinate2D = locationsMapView.convert(touchPt, toCoordinateFrom: locationsMapView)
            let maxMeters: Double = meters(fromPixel: 22, at: touchPt)
            var nearestDistance: Float = MAXFLOAT
            var nearestPoly: MKPolyline? = nil
            for overlay: MKOverlay in locationsMapView.overlays {
                if (overlay is MKPolyline) {
                    let distance: Float = Float(distanceOf(pt: MKMapPoint(coord), toPoly: overlay as! MKPolyline))
                    if distance < nearestDistance {
                        nearestDistance = distance
                        nearestPoly = overlay as? MKPolyline
                    }
                }
            }

            if Double(nearestDistance) <= maxMeters, let polyline = nearestPoly {
                if let route = polylineToRouteMap[polyline] {
                    selectedRoute = route
                    self.locationsMapView.removeOverlays(locationsMapView.overlays)
                    locationsMapView.addOverlays(allRoutes.map(\.polyline))
                }
            }
        }
    }
    
    @IBAction func getGasStationsButtonClicked(_ sender: Any) {
        let gvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GasStationsOnRouteViewController") as? GasStationsOnRouteViewController
        guard let vc = gvc, let selectedOrigin, let selectedDestination, let selectedFuel else { return }
        vc.originLocation = selectedOrigin
        vc.destinationLocation = selectedDestination
        vc.fuel = selectedFuel
        vc.route = selectedRoute
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension RouteViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == originTextField {
            originSuggestionsTableView.isHidden = false
        } else if textField == destinationTextField {
            destinationSuggestionsTableView.isHidden = false
        }
        let query = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        autoCompleteSearch.updateQuery(query)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == originTextField {
            originSuggestionsTableView.isHidden = true
            destinationTextField.becomeFirstResponder()
        } else if textField == destinationTextField {
            destinationSuggestionsTableView.isHidden = true
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == fuelsSelectionTextField {
            return false
        }
        return true
    }
}

extension RouteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == originSuggestionsTableView {
            return originSuggestions.count
        } else if tableView == destinationSuggestionsTableView {
            return destinationSuggestions.count
        } else {
            return fuels.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == originSuggestionsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCellIdentifier", for: indexPath) as! LocationSuggestionTableViewCell
            cell.setUpUI(name: originSuggestions[indexPath.row].title, subtitle: originSuggestions[indexPath.row].subtitle)
            return cell
        } else if tableView == destinationSuggestionsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCellIdentifier", for: indexPath) as! LocationSuggestionTableViewCell
            cell.setUpUI(name: destinationSuggestions[indexPath.row].title, subtitle: destinationSuggestions[indexPath.row].subtitle)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "fuelTableViewCell", for: indexPath) as! FuelTableViewCell
            cell.setUpUI(fuelName: NSLocalizedString(fuels[indexPath.row].nombreProductoAbreviatura, comment: ""), fuelAbb: fuels[indexPath.row].nombreProductoAbreviatura)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isHidden = true
        
        if tableView == originSuggestionsTableView {
            originTextField.text = originSuggestions[indexPath.row].title
            markOriginOnMap(suggestion: originSuggestions[indexPath.row])
        } else if tableView == destinationSuggestionsTableView {
            destinationTextField.text = destinationSuggestions[indexPath.row].title
            markDestinationOnMap(suggestion: destinationSuggestions[indexPath.row])
        } else {
            fuelsSelectionTextField.text = NSLocalizedString(fuels[indexPath.row].nombreProductoAbreviatura, comment: "")
            selectedFuel = fuels[indexPath.row]
        }
    }
}

extension RouteViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            
            // Verificar si esta ruta es la seleccionada
            if let route = allRoutes.first(where: { $0.polyline == polyline }) {
                if route == selectedRoute {
                    renderer.strokeColor = UIColor.systemBlue // Azul oscuro para la ruta seleccionada
                    renderer.lineWidth = 6.0
                } else {
                    renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.3) // Azul claro para rutas alternativas
                    renderer.lineWidth = 10.0
                }
            }
            
            return renderer
        }
        return MKOverlayRenderer()
    }
}

extension RouteViewController: RouteViewModelDelegate {
    func setFuels(fuels: [Carburante]) {
        self.fuels = fuels
        DispatchQueue.main.async {
            self.fuelsTableView.reloadData()
        }
    }
}
