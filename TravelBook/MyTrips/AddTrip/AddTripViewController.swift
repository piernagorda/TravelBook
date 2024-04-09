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
    
    public var callback: (_ close: Bool?, _ tripToAdd: TripModel?) -> Void = {close, tripToAdd in ()}
    private var temporaryTrip = TripModel(locations: [], year: 0, title: "", description: "")

    override func viewDidLoad() {
        table.delegate = self
        table.dataSource = self
        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeModal))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Trip", style: .plain, target: self, action: #selector(addTrip))
        super.viewDidLoad()
        let cell = UINib(nibName: "NameAndDescriptionTableView", bundle: nil)
        table.register(cell, forCellReuseIdentifier: "datacell4")
    }
    
    @IBAction func addLocationsPressed() {
        let addLocationsVC = AddLocationsViewController(nibName: "AddLocationsView", bundle: nil)
        addLocationsVC.callback = { closeModal, locations in
            addLocationsVC.dismiss(animated: true)
            if !closeModal {
                self.temporaryTrip.locations = locations!
            }
        }
        let navC = UINavigationController(rootViewController: addLocationsVC)
        navC.modalPresentationStyle = .formSheet
        navigationController?.present(navC, animated: true)
    }
    
    @objc func addTrip() {
        let textFieldTripName = table.cellForRow(at: IndexPath(row: 0, section: 0)) as? NameAndDescriptionTableViewCell
        let textFieldTripDescription = table.cellForRow(at: IndexPath(row: 1, section: 0)) as? NameAndDescriptionTableViewCell
        let textFieldTripStart = table.cellForRow(at: IndexPath(row: 0, section: 1)) as? NameAndDescriptionTableViewCell
        let textFieldTripEnd = table.cellForRow(at: IndexPath(row: 1, section: 1)) as? NameAndDescriptionTableViewCell
        guard let tripName = textFieldTripName?.textField?.text, let tripDescription = textFieldTripDescription?.textField?.text,
              let tripBeginning = textFieldTripStart?.textField?.text, let tripEnd = textFieldTripEnd?.textField?.text else {
            showIncompleteFieldsError()
            return
        }
        let temporaryTrip = TripModel(locations: temporaryTrip.locations,
                                      year: Int(tripBeginning) ?? 0,
                                      title: tripName,
                                      description: tripDescription)
        callback(false, temporaryTrip)
    }
    
    @objc func closeModal() {
        callback(true, nil)
    }
    
    private func showIncompleteFieldsError() {
        let alertController = UIAlertController(title: "Empty fields!", message: "You need to fill out all the fields", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
