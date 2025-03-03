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
        
        // Callback: should reload data or not. When called we always dismiss the modal
        addTripVC.callback = { reloadData in
            if reloadData {
                self.collectionView.reloadData()
            }
            addTripVC.dismiss(animated: true)
        }
        
        // Navigation to the AddTrip View
        let navC = UINavigationController(rootViewController: addTripVC)
        navC.modalPresentationStyle = .formSheet
        navigationController?.present(navC, animated: true)
    }
    
    private func showError(error: Error) {
        print(error)
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
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
