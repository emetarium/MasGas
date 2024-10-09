//
//  FuelsViewController.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import UIKit
import CoreLocation

protocol OptionsProtocol {
    func loggedOptionSelected(option: LoggedOptions)
    func notLoggedOptionSelected(option: NotLoggedOptions)
}

protocol FuelsProtocol {
    func updateFuels(fuels: [Carburante])
    func updateTown(town: Municipio)
    func navigateToLogin()
    func showNoConnectionAlert()
    func showChangeTownAlert(town: Municipio)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

class FuelsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource
{
    //MARK: - IBOutlets
    @IBOutlet var optionsButton: UIButton!
    @IBOutlet var townLabel: UILabel!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var selectFuelLabel: UILabel!
    @IBOutlet var fuelsTableView: UITableView!
    
    //MARK: - Variables
    var viewModel = FuelsViewModel()
    var fuels: [Carburante] = []
    var town: Municipio?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        setDelegates()
        
        fetchSelectedTown()
        fetchFuels()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Functions
    func fetchSelectedTown() {
        viewModel.fetchSelectedTown()
    }
    
    func fetchFuels() {
        viewModel.getFuels()
    }
    
    func setUpUI() {
        guard let town = self.town else {
            return
        }
        
        self.view.backgroundColor = Colors.darkGray
        
        self.townLabel.attributedText = NSAttributedString(string: town.nombreMunicipio.formatName(), attributes: [NSAttributedString.Key.foregroundColor : Colors.white, NSAttributedString.Key.underlineColor : Colors.white, NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font : Fonts.montserratx17])
        
        self.optionsButton.tintColor = Colors.white
        self.optionsButton.setTitle("", for: .normal)
        
        self.selectFuelLabel.font = Fonts.montserratx24
        self.selectFuelLabel.text = NSLocalizedString("FUEL_SELECTION_LABEL", comment: "")
        self.selectFuelLabel.textColor = Colors.white
        
        self.backgroundImage.image = UIImage(named: "gasStationImage")
        self.backgroundImage.contentMode = .scaleAspectFill
        
        self.setUpTapGesture()
        self.registerCell()
        self.setUpTableView()
    }
    
    func setDelegates() {
        viewModel.delegate = self
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
    @IBAction func optionsButtonPressed(_ sender: Any) {
        let ovc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OptionsTableViewController") as? OptionsTableViewController
        guard let vc = ovc else { return }
        vc.delegate = self
        if viewModel.isUserLogged() {
            vc.preferredContentSize = CGSize(width: self.view.frame.width * 0.66, height: 120)
        } else {
            vc.preferredContentSize = CGSize(width: self.view.frame.width * 0.66, height: 80)
        }
        vc.modalPresentationStyle = .popover
        if let pres = vc.presentationController {
            pres.delegate = self
        }
        if let pop = vc.popoverPresentationController {
            pop.sourceView = self.optionsButton
        }
        self.present(vc, animated: true, completion: nil)
    }
}

extension FuelsViewController: OptionsProtocol {
    func loggedOptionSelected(option: LoggedOptions) {
        switch option {
        case .logout:
            let accept = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .destructive) { accepted in
                self.viewModel.logout()
            }
            let cancel = UIAlertAction(title: NSLocalizedString("CANCEL_ACTION", comment: ""), style: .default)
            self.showAlert(title: NSLocalizedString("LOG_OUT_ALERT_TITLE", comment: ""), message: NSLocalizedString("LOG_OUT_ALERT_MESSAGE", comment: ""), alternativeAction: cancel, acceptAction: accept)
        case .deleteAccount:
            let accept = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .destructive) { accepted in
                self.viewModel.deleteAccount()
            }
            let cancel = UIAlertAction(title: NSLocalizedString("CANCEL_ACTION", comment: ""), style: .default)
            self.showAlert(title: NSLocalizedString("DELETE_ACCOUNT_ALERT_TITLE", comment: ""), message: NSLocalizedString("DELETE_ACCOUNT_ALERT_MESSAGE", comment: ""), alternativeAction: cancel, acceptAction: accept)
        case .about:
            let avc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController
            guard let vc = avc else { return }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func notLoggedOptionSelected(option: NotLoggedOptions) {
        switch option {
        case .login:
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            guard let vc = loginVC else { return }
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
        case .about:
            let avc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController
            guard let vc = avc else { return }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension FuelsViewController: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension FuelsViewController: FuelsViewModelDelegate {
    func setFuels(fuels: [Carburante]) {
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
    
    func setSelectedTown(town: Municipio) {
        self.town = town
        DispatchQueue.main.async {
            self.townLabel.attributedText = NSAttributedString(string: town.nombreMunicipio.formatName(), attributes: [NSAttributedString.Key.foregroundColor : Colors.white, NSAttributedString.Key.underlineColor : Colors.white, NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font : Fonts.montserratx17])
        }
    }
    
    func showChangeTownAlert(town: Municipio) {
        let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default) { action in
            self.viewModel.saveTown(town: town)
            self.setSelectedTown(town: town)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL_ACTION", comment: ""), style: .default)
        
        DispatchQueue.main.async {
            let replace: [String : String] = ["[town]" : town.nombreMunicipio.formatName()]
            self.showAlert(title: NSLocalizedString("LOCATION_CHANGED_ALERT_TITLE", comment: ""), message: NSLocalizedString("LOCATION_CHANGED_ALERT_MESSAGE", comment: "").replace(occurrences: replace), alternativeAction: cancelAction, acceptAction: acceptAction)
        }
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
