//
//  QueryOptionsTableViewController.swift
//  MasGas
//
//  Created by María García Torres on 1/3/22.
//

import UIKit

class QueryOptionsTableViewController: UITableViewController {
    
    var delegate: SearchModeProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryByFuelOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        cell.textLabel?.text = NSLocalizedString(queryByFuelOptions.allCases[indexPath.row].rawValue, comment: "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        delegate.updateSearchMode(searchMode: queryByFuelOptions.allCases[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
}
