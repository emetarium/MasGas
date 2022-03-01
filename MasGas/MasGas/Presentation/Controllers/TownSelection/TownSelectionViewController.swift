//
//  TownSelectionViewController.swift
//  MasGas
//
//  Created by María García Torres on 22/2/22.
//

import UIKit

protocol TownSelectionProtocol {
    func navigateToHome(selectedTown: Municipio)
}

class TownSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet var townSearchBar: UISearchBar!
    @IBOutlet var townTableView: UITableView!

    //MARK: - Variables
    var towns: [Municipio] = []
    var filteredTowns: [Municipio] = []
    var fuels: [Carburante] = []
    var presenter: TownSelectionPresenter<TownSelectionViewController>?

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = TownSelectionPresenter(self)
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Functions
    func setUpUI() {
        filteredTowns = towns
        registerCell()
        setUpTableView()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: "TownSelectionTableViewCell", bundle: nil)
        self.townTableView.register(nib, forCellReuseIdentifier: "townSelectionTableViewCell")
    }
    
    private func setUpTableView() {
        self.townTableView.delegate = self
        self.townTableView.dataSource = self
        self.townSearchBar.delegate = self
    }
    
    //MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTowns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = townTableView.dequeueReusableCell(withIdentifier: "townSelectionTableViewCell", for: indexPath) as! TownSelectionTableViewCell
        cell.setUpUI(townName: filteredTowns[indexPath.row].nombreMunicipio)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.saveTown(town: filteredTowns[indexPath.row])
    }
    
    //MARK: - Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredTowns = towns.filter({ municipio in
            if municipio.nombreMunicipio.lowercased().contains(searchText.lowercased()) {
                return true
            }
            else { return false }
        })
        if searchText.isEmpty {
            filteredTowns = towns
        }
        self.townTableView.reloadData()
    }

}

extension TownSelectionViewController: TownSelectionProtocol {
    func navigateToHome(selectedTown: Municipio) {
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? TabBarViewController
        guard let tbc = tabBarController else { return }
        tbc.fuels = fuels
        tbc.town = selectedTown
        tbc.towns = towns
        self.navigationController?.pushViewController(tbc, animated: true)
    }
}
