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
    var selectedOrigin: MKPointAnnotation?
    var selectedDestination: MKPointAnnotation?
    var selectedFuel: Carburante?
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
        self.originLabel.text = "Origen"
        
        self.destinationLabel.font = Fonts.montserratx13
        self.destinationLabel.textColor = Colors.black
        self.destinationLabel.text = "Destino"
        
        self.getGasStationsOnRouteButton.style = .filled
        self.getGasStationsOnRouteButton.setTitle("Buscar gasolineras", for: .normal)
        
        self.originSuggestionsTableView.dropShadow()
        self.originSuggestionsTableView.isHidden = true
        self.originSuggestionsTableView.roundCorners(corners: [.layerMinXMaxYCorner, . layerMaxXMaxYCorner], radius: 4)
        
        self.destinationSuggestionsTableView.dropShadow()
        self.destinationSuggestionsTableView.isHidden = true
        self.destinationSuggestionsTableView.roundCorners(corners: [.layerMinXMaxYCorner, . layerMaxXMaxYCorner], radius: 4)
        
        guard let dropdownImage = UIImage(named: "downArrow") else { return }
        self.fuelsSelectionTextField.setRightIcon(dropdownImage.withTintColor(Colors.darkGray))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openFuelsDropdownMenu))
        self.fuelsSelectionTextField.isUserInteractionEnabled = true
        self.fuelsSelectionTextField.addGestureRecognizer(tapGesture)
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
            guard let response = response, let mapItem = response.mapItems.first, error == nil else {
                print("Error realizando la búsqueda: \(error?.localizedDescription ?? "Desconocido")")
                return
            }
            
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
            guard let response = response, let mapItem = response.mapItems.first, error == nil else {
                print("Error realizando la búsqueda: \(error?.localizedDescription ?? "Desconocido")")
                return
            }
            
            let coordinate = mapItem.placemark.coordinate
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            self.selectedDestination = annotation
            
            self.locationsMapView.addAnnotation(annotation)
            self.locationsMapView.showAnnotations(self.locationsMapView.annotations, animated: true)
        }
    }
    
    func setGestureHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.locationsView.addGestureRecognizer(tap)
        self.locationsMapView.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func openFuelsDropdownMenu() {
        fuelsTableView.isHidden = !fuelsTableView.isHidden
        guard let downImage = UIImage(named: "downArrow"), let upImage = UIImage(named: "upArrow") else { return }
        if fuelsTableView.isHidden {
            self.fuelsTableViewHeight.constant = 0
            self.fuelsSelectionTextField.setRightIcon(downImage.withTintColor(Colors.darkGray))
        } else {
            self.fuelsTableViewHeight.constant = fuelsTableView.contentSize.height
            self.fuelsSelectionTextField.setRightIcon(upImage.withTintColor(Colors.darkGray))
        }
        self.view.layoutIfNeeded()
    }
    
    @IBAction func getGasStationsButtonClicked(_ sender: Any) {
        let gvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GasStationsOnRouteViewController") as? GasStationsOnRouteViewController
        guard let vc = gvc, let selectedOrigin, let selectedDestination, let selectedFuel else { return }
        vc.originLocation = selectedOrigin
        vc.destinationLocation = selectedDestination
        vc.fuel = selectedFuel
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
            cell.setUpUI(fuelName: fuels[indexPath.row].nombreProducto, fuelAbb: fuels[indexPath.row].nombreProductoAbreviatura)
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
            fuelsSelectionTextField.text = fuels[indexPath.row].nombreProducto
            selectedFuel = fuels[indexPath.row]
        }
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
