import UIKit
import Firebase
import FirebaseFirestore

let reuseIdentifier = "datacell"

class MyTripsCollectionViewController: UICollectionViewController {
    
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
        super.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func addTripPressed() {
        let addTripVC = AddTripViewController(nibName: "AddTripView", bundle: nil)
        addTripVC.callback = { closeModal, tripToAdd in
            addTripVC.dismiss(animated: true)
            if !closeModal! {
                self.sendTripToDatabase(trip: tripToAdd!) { good, error  in
                    if error != nil {
                        print("Error adding the trip in the DB...")
                    } else {
                        currentUser?.addTrip(trip: tripToAdd!)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        let navC = UINavigationController(rootViewController: addTripVC)
        navC.modalPresentationStyle = .formSheet
        navigationController?.present(navC, animated: true)
    }
    
    private func sendTripToDatabase(trip: TripModel, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document("as23912sda")
        
        do {
            // Convert Trip struct to JSON data
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(trip)
            // Convert JSON data to a dictionary
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            // Make sure jsonObject is a dictionary
            guard let tripDictionary = jsonObject as? [String: Any] else {
                print("Failed to convert JSON data to dictionary.")
                completion(false, NSError(domain: "ConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON data to dictionary."]))
                return
            }
            // Update the array field by appending the new trip
            userRef.updateData([
                "trips": FieldValue.arrayUnion([tripDictionary])
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                    completion(false, error)
                } else {
                    print("Document successfully updated with new trip!")
                    completion(true, nil)
                }
            }
        } catch {
            print("Error encoding trip: \(error)")
            completion(false, error)
        }
    }
}

extension MyTripsCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { currentUser!.trips.count }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MyTripsViewCell else {
            return UICollectionViewCell()
        }
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = true
        cell.titleLabel?.text = currentUser!.trips[indexPath.row].title
        cell.yearLabel?.text = "\(currentUser!.trips[indexPath.row].year)"
        cell.image?.image = UIImage(named: currentUser!.trips[indexPath.row].tripImage ?? "default-image")
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = TripViewController(nibName: "TripView", bundle: nil)
        vc.index = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
    }
}
