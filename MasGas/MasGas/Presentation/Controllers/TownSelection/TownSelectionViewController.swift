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

class TownSelectionViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - IBOutlets
    @IBOutlet var townSearchBar: UISearchBar!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var townTableView: UITableView!
    @IBOutlet var navigationBarItem: UINavigationItem!
    
    //MARK: - Variables
    var towns: [Municipio] = []
    var filteredTowns: [Municipio] = []
    var viewModel = TownSelectionViewModel()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        setDelegates()
        fetchTowns()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Functions
    func setUpUI() {
        self.navigationController?.isNavigationBarHidden = true
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = Colors.white
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat", size: 15)!, NSAttributedString.Key.foregroundColor: Colors.black]
        self.navigationBarItem.title = NSLocalizedString("TOWN_SELECTION_TITLE", comment: "")
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(popToPrevious))
        barButtonItem.tintColor = Colors.green
        self.navigationBarItem.leftBarButtonItem = barButtonItem
                                                                   
        townSearchBar.searchBarStyle = .minimal
        
        registerCell()
        setUpTableView()
    }
    
    func setDelegates() {
        viewModel.delegate = self
    }
    
    func fetchTowns() {
        viewModel.fetchTowns()
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
                                                                   
   @objc private func popToPrevious() {
       self.navigationController?.popViewController(animated: true)
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
        viewModel.saveTown(town: filteredTowns[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TownSelectionViewController: UISearchBarDelegate {
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension TownSelectionViewController: TownSelectionViewModelDelegate {
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
