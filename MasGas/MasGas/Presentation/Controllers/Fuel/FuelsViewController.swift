//
//  FuelsViewController.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import UIKit
import CoreLocation

protocol FuelsProtocol {
    func updateFuels(fuels: [Carburante])
    func updateTown(town: Municipio)
    func navigateToLogin()
    func showNoConnectionAlert()
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

class FuelsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource
{
    //MARK: - IBOutlets
    @IBOutlet var townLabel: UILabel!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var selectFuelLabel: UILabel!
    @IBOutlet var fuelsTableView: UITableView!
    
    //MARK: - Variables
    var presenter: FuelsPresenter<FuelsViewController>?
    var fuels: [Carburante] = []
    var town: Municipio?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = FuelsPresenter(self)
        fetchSelectedTown()
        fetchFuels()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter?.checkInternetConnection()
    }
    
    //MARK: - Functions
    func fetchSelectedTown() {
        presenter?.fetchSelectedTown()
    }
    
    func fetchFuels() {
        presenter?.fetchFuels()
    }
    
    func setUpUI() {
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        guard let town = self.town else {
            return
        }
        
        self.view.backgroundColor = Colors.darkGray
        
        self.townLabel.textColor = Colors.white
        self.townLabel.text = town.nombreMunicipio
        
        self.logoutButton.tintColor = Colors.white
        self.logoutButton.setTitle("", for: .normal)
        
        self.selectFuelLabel.text = NSLocalizedString("FUEL_SELECTION_LABEL", comment: "")
        self.selectFuelLabel.textColor = Colors.white
        
        self.backgroundImage.image = UIImage(named: "gasStationImage")
        self.backgroundImage.contentMode = .scaleAspectFill
        
        self.setUpTapGesture()
        self.registerCell()
        self.setUpTableView()
    }
    
    private func setUpTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectTown))
        self.townLabel.isUserInteractionEnabled = true
        self.townLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func registerCell() {
        let nib = UINib(nibName: "FuelTableViewCell", bundle: nil)
        self.fuelsTableView.register(nib, forCellReuseIdentifier: "fuelTableViewCell")
    }
    
    private func setUpTableView() {
        self.fuelsTableView.delegate = self
        self.fuelsTableView.dataSource = self
    }
    
    @objc func selectTown() {
        let townSelectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TownSelectionViewController") as? TownSelectionViewController
        guard let tvc = townSelectionViewController else { return }
        self.navigationController?.pushViewController(tvc, animated: true)
    }
    
    //MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fuels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = fuelsTableView.dequeueReusableCell(withIdentifier: "fuelTableViewCell", for: indexPath) as! FuelTableViewCell
        cell.setUpUI(fuelName: NSLocalizedString(fuels[indexPath.row].nombreProductoAbreviatura, comment: ""), fuelAbb: fuels[indexPath.row].nombreProductoAbreviatura)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let qvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchFuelViewController") as? SearchFuelViewController
        guard let vc = qvc else { return }
        vc.fuel = fuels[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - IBActions
    @IBAction func logoutButton(_ sender: Any) {
        let accept = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .destructive) { accepted in
            self.presenter?.logout()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("CANCEL_ACTION", comment: ""), style: .default)
        self.showAlert(title: NSLocalizedString("LOG_OUT_ALERT_TITLE", comment: ""), message: NSLocalizedString("LOG_OUT_ALERT_MESSAGE", comment: ""), alternativeAction: cancel, acceptAction: accept)
    }
}

extension FuelsViewController: FuelsProtocol {
    func updateTown(town: Municipio) {
        self.town = town
    }
    
    func updateFuels(fuels: [Carburante]) {
        self.fuels = fuels
        DispatchQueue.main.async {
            self.fuelsTableView.reloadData()
        }
    }
    
    func navigateToLogin() {
        let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        guard let vc = loginViewController else { return }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
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
