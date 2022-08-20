//
//  OptionsTableViewController.swift
//  MasGas
//
//  Created by María García Torres on 20/8/22.
//

import UIKit

class OptionsTableViewController: UITableViewController {
    
    var delegate: OptionsProtocol?
    var presenter: OptionsPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = OptionsPresenter(self)
        registerCell()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: "OptionsTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "optionsCellIdentifier")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let logged = presenter?.isUserLogged() {
            if logged {
                return LoggedOptions.allCases.count
            } else {
                return NotLoggedOptions.allCases.count
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCellIdentifier", for: indexPath) as! OptionsTableViewCell
        
        if let logged = presenter?.isUserLogged() {
            if logged {
                guard let option = LoggedOptions(rawValue: indexPath.row) else { return UITableViewCell() }
                cell.setUpUI(icon: option.icon, title: option.description)
                return cell
            } else {
                guard let option = NotLoggedOptions(rawValue: indexPath.row) else { return UITableViewCell() }
                cell.setUpUI(icon: option.icon, title: option.description)
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        if let logged = presenter?.isUserLogged() {
            if logged {
                guard let option = LoggedOptions(rawValue: indexPath.row), let delegate = delegate else { return }
                delegate.loggedOptionSelected(option: option)
            } else {
                guard let option = NotLoggedOptions(rawValue: indexPath.row), let delegate = delegate else { return }
                delegate.notLoggedOptionSelected(option: option)
            }
        }
    }
}
