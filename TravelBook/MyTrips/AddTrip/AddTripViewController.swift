//
//  AddTripViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-31.
//

import UIKit

class AddTripViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var image: UIImageView?
    @IBOutlet weak var choosePhotoButton: UIButton?
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var addLocationsButton: UIButton?
    public var temporaryTrip = TripModel(locations: [], year: 0, title: "", description: "")
    private let addLocationsVC = AddLocationsViewController(nibName: "AddLocationsView", bundle: nil)

    override func viewDidLoad() {
        table.delegate = self
        table.dataSource = self
        super.viewDidLoad()
        let second = UINib(nibName: "NameAndDescriptionTableView", bundle: nil)
        table.register(second, forCellReuseIdentifier: "datacell4")
    }
    
    @IBAction func addLocationsPressed() {
        let navC = UINavigationController(rootViewController: addLocationsVC)
        navC.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeModal))
        navC.modalPresentationStyle = .formSheet
        navC.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Locations", style: .plain, target: self, action: #selector(addLocations))
        navC.modalPresentationStyle = .formSheet
        navigationController?.present(navC, animated: true)
    }
    
    // Methods of the next view
    @objc func closeModal() {
        dismiss(animated: true)
    }
    
    @objc func addLocations() {
        temporaryTrip.locations = addLocationsVC.countriesInTrip
        dismiss(animated: true)
    }
}

extension AddTripViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 50 }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 20 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "datacell4", for: indexPath) as? NameAndDescriptionTableViewCell else {
            return UITableViewCell()
        }
        cell.imageView?.tintColor = .black
        cell.selectionStyle = .none
        if indexPath.section == 0{
            if indexPath.row == 0 {
                cell.imageView?.image = UIImage(systemName: "tag")
                cell.textField?.placeholder = "Name of the trip"
            } else{
                cell.imageView?.image = UIImage(systemName: "line.3.horizontal")
                cell.textField?.placeholder = "Brief description of the trip"
            }
        } else {
            if indexPath.row == 0 {
                cell.imageView?.image = UIImage(systemName: "calendar")
                cell.textField?.placeholder = "Start Date (dd/MM/YYYY)"
            } else{
                cell.imageView?.image = UIImage(systemName: "calendar.badge.checkmark")
                cell.textField?.placeholder = "End Date (dd/MM/YYYY)"
            }
        }
        return cell
    }
}
