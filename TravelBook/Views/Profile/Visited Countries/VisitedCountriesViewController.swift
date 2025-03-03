//
//  TableViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 3/3/25.
//

import UIKit

class VisitedCountriesViewController: UITableViewController {
    
    var keysArray: Array<String> = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser {
            keysArray = Array(currentUser.visitedCountriesAndAppearances.keys.sorted())
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard currentUser != nil else {
            return 0
        }
        return keysArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        guard currentUser != nil else {
            return cell
        }
        cell.textLabel?.text = alpha2CodeToCountry[keysArray[indexPath.row].uppercased()]

        return cell
    }
}
