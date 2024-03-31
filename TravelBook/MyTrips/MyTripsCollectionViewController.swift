import UIKit

let reuseIdentifier = "datacell"

class MyTripsCollectionViewController: UICollectionViewController {
    
    let addTripVC = AddTripViewController(nibName: "AddTripView", bundle: nil)
    
    override func viewDidLoad() {
        let nib = UINib(nibName: "MyTripsViewCell", bundle: nil)
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.topViewController?.navigationItem.leftBarButtonItem?.tintColor = .black
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addTripPressed))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc func addTripPressed() {
        let navC = UINavigationController(rootViewController: addTripVC)
        navC.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeModal))
        navC.modalPresentationStyle = .formSheet
        navC.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Trip", style: .plain, target: self, action: #selector(addTrip))
        navC.modalPresentationStyle = .formSheet
        navigationController?.present(navC, animated: true)
    }
    
    // Methods of the next view
    @objc func closeModal() {
        dismiss(animated: true)
    }
    
    @objc func addTrip() {
        let textFieldTripName = addTripVC.table.cellForRow(at: IndexPath(row: 0, section: 0)) as? NameAndDescriptionTableViewCell
        let textFieldTripDescription = addTripVC.table.cellForRow(at: IndexPath(row: 1, section: 0)) as? NameAndDescriptionTableViewCell
        let textFieldTripStart = addTripVC.table.cellForRow(at: IndexPath(row: 0, section: 1)) as? NameAndDescriptionTableViewCell
        let textFieldTripEnd = addTripVC.table.cellForRow(at: IndexPath(row: 1, section: 1)) as? NameAndDescriptionTableViewCell
        if textFieldTripName?.textField?.text != "" && textFieldTripDescription?.textField?.text != ""
            && textFieldTripStart?.textField?.text != "" && textFieldTripEnd?.textField?.text != "" {
            print("Tiene texto!")
            collectionView.reloadData()
            dismiss(animated: true)
        } else {
            let alertController = UIAlertController(title: "Empty fields!", message: "You need to fill all the fields out", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            addTripVC.present(alertController, animated: true, completion: nil)
        }
    }
}

extension MyTripsCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { mockUser!.trips.count }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MyTripsViewCell else {
            return UICollectionViewCell()
        }
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = true
        cell.titleLabel?.text = mockUser!.trips[indexPath.row].title
        cell.yearLabel?.text = "\(mockUser!.trips[indexPath.row].year)"
        cell.image?.image = mockUser!.trips[indexPath.row].tripImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = TripViewController(nibName: "TripView", bundle: nil)
        vc.index = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
    }
}
