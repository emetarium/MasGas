//
//  TownSelectionViewController.swift
//  MasGas
//
//  Created by María García Torres on 22/2/22.
//

import UIKit

protocol TownSelectionProtocol {
    func updateTowns(towns: [Municipio])
    func navigateToTabBar(selectedTown: Municipio)
    func showNoConnectionAlert()
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

class TownSelectionViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet var townSearchBar: UISearchBar!
    @IBOutlet var townTableView: UITableView!

    //MARK: - Variables
    var towns: [Municipio] = []
    var filteredTowns: [Municipio] = []
    var presenter: TownSelectionPresenter<TownSelectionViewController>?

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = TownSelectionPresenter(self)
        fetchTowns()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Functions
    func setUpUI() {
        self.navigationController?.isNavigationBarHidden = false
        registerCell()
        setUpTableView()
    }
    
    func fetchTowns() {
        presenter?.fetchTowns()
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
            if municipio.nombreMunicipio.applyingTransform(.stripDiacritics, reverse: false)!.lowercased().contains(searchText.applyingTransform(.stripDiacritics, reverse: false)!.lowercased()) {
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
    func updateTowns(towns: [Municipio]) {
        self.towns = towns
        self.filteredTowns = towns
        DispatchQueue.main.async {
            self.townTableView.reloadData()
        }
    }
    
    func navigateToTabBar(selectedTown: Municipio) {
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? TabBarViewController
        guard let tbc = tabBarController else { return }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tbc)
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
