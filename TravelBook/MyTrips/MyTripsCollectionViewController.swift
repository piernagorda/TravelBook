import UIKit

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
    }
    
    @objc func addTripPressed() {
        let addTripVC = AddTripViewController(nibName: "AddTripView", bundle: nil)
        addTripVC.callback = { closeModal, tripToAdd in
            addTripVC.dismiss(animated: true)
            if !closeModal! {
                mockUser?.addTrip(trip: tripToAdd!)
                self.collectionView.reloadData()
            }
        }
        let navC = UINavigationController(rootViewController: addTripVC)
        navC.modalPresentationStyle = .formSheet
        navigationController?.present(navC, animated: true)
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
