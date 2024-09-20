//
//  SearchFuelViewController.swift
//  MasGas
//
//  Created by María García Torres on 22/2/22.
//

import UIKit
import CoreLocation

protocol SearchModeProtocol {
    func updateSearchMode(searchMode: queryByFuelOptions)
}

protocol SearchFuelProtocol {
    func updateFuelList(fuelList: [BusquedaCarburante])
    func showNoConnectionAlert()
    func showNoLocationPermissionAlert()
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

class SearchFuelViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet var headerView: UIView!
    @IBOutlet var fuelView: UIView!
    @IBOutlet var fuelColorIcon: UIImageView!
    @IBOutlet var fuelLabel: UILabel!
    @IBOutlet var searchModeLabel: UILabel!
    @IBOutlet var fuelPricesTableView: UITableView!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var navigationBarItem: UINavigationItem!
    
    //MARK: - Variables
    var presenter: SearchFuelPresenter<SearchFuelViewController>?
    var fuel: Carburante?
    var searchMode: queryByFuelOptions = .queryByCheapestNearby
    var fuelList: [BusquedaCarburante]?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SearchFuelPresenter(self)
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Functions
    func setUpUI() {
        guard let fuel = fuel else {
            return
        }
        self.view.backgroundColor = Colors.darkGray
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = Colors.darkGray
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat", size: 15)!, NSAttributedString.Key.foregroundColor: Colors.white]
        self.navigationBarItem.title = NSLocalizedString("QUERY_FUEL_TITLE", comment: "")
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(popToPrevious))
        barButtonItem.tintColor = Colors.white
        self.navigationBarItem.leftBarButtonItem = barButtonItem
        
        self.fuelLabel.text = NSLocalizedString(fuel.nombreProductoAbreviatura, comment: "")
        self.fuelView.backgroundColor = Colors.white
        self.fuelView.layer.cornerRadius = 5
        
        self.searchModeLabel.textColor = Colors.white
        self.searchModeLabel.text = NSLocalizedString(searchMode.rawValue, comment: "")
        
        self.fuelColorIcon.tintColor = UIColor(named: fuel.nombreProductoAbreviatura)
        self.headerView.backgroundColor = Colors.darkGray
        
        setUpTapGesture()
        registerCell()
        setUpTableView()
        searchFuel(fuel: fuel)
        presenter?.checkInternetConnection()
    }
    
    func searchFuel(fuel: Carburante) {
        self.presenter?.searchFuel(fuel: fuel)
    }
    
    @objc private func popToPrevious() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showOptionsPopover() {
        let ovc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QueryOptionsTableViewController") as? QueryOptionsTableViewController
        guard let vc = ovc else { return }
        vc.delegate = self
        vc.preferredContentSize = CGSize(width: 300, height: 130.5)
        vc.modalPresentationStyle = .popover
        if let pres = vc.presentationController {
            pres.delegate = self
        }
        if let pop = vc.popoverPresentationController {
            pop.sourceView = self.searchModeLabel
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func setUpTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOptionsPopover))
        self.searchModeLabel.isUserInteractionEnabled = true
        self.searchModeLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func registerCell() {
        let nib = UINib(nibName: "QueryFuelTableViewCell", bundle: nil)
        self.fuelPricesTableView.register(nib, forCellReuseIdentifier: "queryFuelCell")
    }
    
    private func setUpTableView() {
        self.fuelPricesTableView.delegate = self
        self.fuelPricesTableView.dataSource = self
        self.fuelPricesTableView.separatorStyle = .none
        self.fuelPricesTableView.backgroundColor = Colors.lightGray
    }
    
    //MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("SUGGESTED_GAS_STATIONS_TITLE", comment: "")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fuelList = fuelList else {
            return 0
        }
        if fuelList.isEmpty {
            let accept = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default) { action in
                self.popToPrevious()
            }
            self.showAlert(title: "", message: NSLocalizedString("NO_FUEL_IN_TOWN", comment: ""), alternativeAction: nil, acceptAction: accept)
        }
        return fuelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = fuelPricesTableView.dequeueReusableCell(withIdentifier: "queryFuelCell", for: indexPath) as! QueryFuelTableViewCell
        guard let fuelList = fuelList else {
            return cell
        }
        cell.setUpUI(price: fuelList[indexPath.row].precioProducto, gasStationName: fuelList[indexPath.row].nombre, gasStationSchedule: fuelList[indexPath.row].horario, distanceToGasStation: fuelList[indexPath.row].distancia)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GasStationLocationViewController") as? GasStationLocationViewController
        guard let vc = gvc, let fuelList = fuelList, let isLogged = presenter?.isUserLogged(), let fuel else { return }
        if isLogged {
            presenter?.isFavorite(gasStation: fuelList[indexPath.row], completion: { result in
                let gasolinera = Gasolinera(nombre: fuelList[indexPath.row].nombre, ubicacion: fuelList[indexPath.row].coordenadas, direccion: fuelList[indexPath.row].direccion, municipio: fuelList[indexPath.row].municipio, favorita: result, id: fuelList[indexPath.row].id)
                let preciosGasolinera = PreciosGasolinera(gasolinera: gasolinera, precios: [PrecioCarburante(carburante: fuel, precio: fuelList[indexPath.row].precioProducto)])
                vc.gasStation = preciosGasolinera
                self.navigationController?.pushViewController(vc, animated: true)
            })
        } else {
            let gasolinera = Gasolinera(nombre: fuelList[indexPath.row].nombre, ubicacion: fuelList[indexPath.row].coordenadas, direccion: fuelList[indexPath.row].direccion, municipio: fuelList[indexPath.row].municipio, favorita: false, id: fuelList[indexPath.row].id)
            let preciosGasolinera = PreciosGasolinera(gasolinera: gasolinera, precios: [PrecioCarburante(carburante: fuel, precio: fuelList[indexPath.row].precioProducto)])
            vc.gasStation = preciosGasolinera
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SearchFuelViewController: SearchModeProtocol {
    func updateSearchMode(searchMode: queryByFuelOptions) {
        self.searchMode = searchMode
        self.searchModeLabel.text = NSLocalizedString(searchMode.rawValue, comment: "")
        guard let fuelList = fuelList else { return }
        self.presenter?.sortFuels(searchMode: searchMode, fuelList: fuelList)
        DispatchQueue.main.async {
            self.fuelPricesTableView.reloadData()
        }
    }
}

extension SearchFuelViewController: SearchFuelProtocol {
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
    
    func updateFuelList(fuelList: [BusquedaCarburante]) {
        self.fuelList = fuelList
        DispatchQueue.main.async {
            self.fuelPricesTableView.reloadData()
        }
    }
    
    func showNoConnectionAlert() {
        let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default) { action in
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }
        self.showAlert(title: NSLocalizedString("NO_CONNECTION_ERROR_TITLE", comment: ""), message: NSLocalizedString("NO_CONNECTION_ERROR_MESSAGE", comment: ""), alternativeAction: nil, acceptAction: acceptAction)
    }
    
    func showNoLocationPermissionAlert() {
        let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default)
        self.showAlert(title: NSLocalizedString("NO_LOCATION_PERMISSION_MESSAGE", comment: ""), message: "", alternativeAction: nil, acceptAction: acceptAction)
    }
}
