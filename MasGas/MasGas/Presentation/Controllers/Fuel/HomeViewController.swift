//
//  HomeViewController.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import UIKit

protocol HomeProtocol {
    func navigateToLogin()
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    //MARK: - IBOutlets
    @IBOutlet var townLabel: UILabel!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var selectFuelLabel: UILabel!
    @IBOutlet var fuelsTableView: UITableView!
    
    var presenter: HomePresenter<HomeViewController>?
    var fuels: [Carburante] = []
    var towns: [Municipio] = []
    var town: Municipio?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = HomePresenter(self)
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Functions
    func setUpUI() {
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        guard let town = town else {
            return
        }
        self.townLabel.textColor = Colors.white
        self.townLabel.text = town.nombreMunicipio
        
        self.logoutButton.tintColor = Colors.white
        
        self.selectFuelLabel.text = NSLocalizedString("FUEL_SELECTION_LABEL", comment: "")
        self.selectFuelLabel.textColor = Colors.white
        
        self.backgroundImage.image = UIImage(named: "gasStationImage")
        self.backgroundImage.contentMode = .scaleAspectFill
        
        setUpTapGesture()
        registerCell()
        setUpTableView()
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
        self.fuelsTableView.isScrollEnabled = false
    }
    
    @objc func selectTown() {
        let townSelectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TownSelectionViewController") as? TownSelectionViewController
        guard let tvc = townSelectionViewController else { return }
        tvc.towns = towns
        tvc.fuels = fuels
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
        cell.setUpUI(fuelName: fuels[indexPath.row].nombreProducto, fuelAbb: fuels[indexPath.row].nombreProductoAbreviatura)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK: - IBActions
    @IBAction func logoutButton(_ sender: Any) {
        presenter?.logout()
    }
}

extension HomeViewController: HomeProtocol {
    func navigateToLogin() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
