//
//  AddTripViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-31.
//

import UIKit
import Photos

class AddTripViewController: UIViewController,
                             UITableViewDelegate,
                             UITableViewDataSource,
                             UIImagePickerControllerDelegate,
                             UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var choosePhotoButton: UIButton?
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var addLocationsButton: UIButton?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    lazy var imagePicker = UIImagePickerController()

    
    public var callback: (_ reloadData: Bool) -> Void = { reloadData in }
    private var temporaryTrip = TripModel(locations: [], year: 0, title: "", tripImage: nil, tripImageURL: nil, description: "", tripId: "")

    override func viewDidLoad() {
        table.delegate = self
        table.dataSource = self
        imageView?.layer.masksToBounds = true
        imageView?.layer.borderWidth = 1
        imageView?.layer.borderColor = UIColor.black.cgColor
        imageView?.layer.cornerRadius = 5
        navigationController?.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeModal))
        navigationController?.topViewController?.navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Trip", style: .plain, target: self, action: #selector(addTrip))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem?.tintColor = .black
        super.viewDidLoad()
        let cell = UINib(nibName: "NameAndDescriptionTableView", bundle: nil)
        table.register(cell, forCellReuseIdentifier: "datacell4")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imagePicker.delegate = nil // When dismissing or deinitializing
    }
    
    @IBAction func addLocationsPressed() {
        let addLocationsVC = AddLocationsViewController(nibName: "AddLocationsView", bundle: nil)
        
        addLocationsVC.callback = { [weak self, weak addLocationsVC] closeModal, locations in
            addLocationsVC?.dismiss(animated: true)
            if !closeModal {
                self?.temporaryTrip.locations = locations!
            }
        }
        let navC = UINavigationController(rootViewController: addLocationsVC)
        navC.modalPresentationStyle = .formSheet
        navigationController?.present(navC, animated: true)
    }
    
    @IBAction func choosePhotoPressed(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            if status == .authorized {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        self.imagePicker.delegate = self
                        self.imagePicker.sourceType = .photoLibrary
                        self.imagePicker.allowsEditing = false
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView!.image = image
        }
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
        
        // The tripImageURL will be nil until we send it to Firebase Storage and get a link to it
        let randomID = UUID().uuidString
        
        let temporaryTrip = TripModel(locations: temporaryTrip.locations,
                                      year: Int(tripBeginning) ?? 0,
                                      title: tripName,
                                      tripImage: imageView?.image,
                                      tripImageURL: nil,
                                      description: tripDescription,
                                      tripId: randomID)
        let repository = Repository()
        activityIndicator.startAnimating()
        repository.addTrip(trip: temporaryTrip) { [weak self] result in
            if result {
                self?.activityIndicator.stopAnimating()
                self?.callback(true)
            } else {
                // show error
            }
        }
    }
    
    @objc func closeModal() {
        callback(false)
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
