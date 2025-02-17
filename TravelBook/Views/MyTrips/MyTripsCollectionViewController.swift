import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

let reuseIdentifier = "datacell"

class MyTripsCollectionViewController: UICollectionViewController {
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        let nib = UINib(nibName: "MyTripsViewCell", bundle: nil)
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.topViewController?.navigationItem.leftBarButtonItem = nil
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addTripPressed))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem?.tintColor = .black
        super.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func addTripPressed() {
        let addTripVC = AddTripViewController(nibName: "AddTripView", bundle: nil)
        addTripVC.callback = { [weak self] closeModal, tripToAdd in
            if !closeModal {
                self?.uploadPhoto(image: (tripToAdd?.tripImage)!) { imageURL in
                    if let imageURL = imageURL  {
                        tripToAdd!.tripImageURL = imageURL
                        self?.sendTripToDatabase(trip: tripToAdd!) { good, error  in
                            if error != nil {
                                print("Error adding the trip in the DB...")
                            } else {
                                currentUser?.addTrip(trip: tripToAdd!)
                                self?.collectionView.reloadData()
                            }
                            addTripVC.dismiss(animated: true)
                        }
                    } else {
                        print("There was an error uploading the photo...")
                    }
                }
            } else {
                addTripVC.dismiss(animated: true)
            }
        }
        let navC = UINavigationController(rootViewController: addTripVC)
        navC.modalPresentationStyle = .formSheet
        navigationController?.present(navC, animated: true)
    }
    
    private func sendTripToDatabase(trip: TripModel, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser!.userId)
        
        do {
            // Convert Trip struct to JSON data
            let encoder = JSONEncoder()
            let tripEntity = trip.toTripEntity()
            let jsonData = try encoder.encode(tripEntity)
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
    
    func uploadPhoto(image: UIImage, completion: @escaping (_ imageURL: String?) -> Void) {
        // Convert the image to data
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            // Create a reference in Firebase Storage
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
            // Upload the image
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                } else {
                    // Get the download URL after the image is uploaded
                    imageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error getting download URL: \(error.localizedDescription)")
                            completion(nil)
                        } else if let url = url {
                            completion(url.absoluteString)
                        }
                    }
                }
            }
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
        
        cell.titleLabel?.text = currentUser!.trips[indexPath.row].title
        cell.yearLabel?.text = "\(currentUser!.trips[indexPath.row].year)"
        
        if let largeImage = currentUser!.trips[indexPath.row].tripImage {
            cell.image?.image = resizeImage(largeImage, targetSize: CGSize(width: screenWidth/3, height: screenHeight/3))
            cell.image?.contentMode = .scaleToFill
        } else {
            cell.image?.image = currentUser!.trips[indexPath.row].tripImage
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Configuring the destination view controller
        let vc = TripViewController(nibName: "TripView", bundle: nil)
        vc.index = indexPath.row
        // This callback is called when deleting a trip
        vc.callback = { self.collectionView.reloadData() }
        // Navigate to it
        navigationController?.pushViewController(vc, animated: true)
    }
}
