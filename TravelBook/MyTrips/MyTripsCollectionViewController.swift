//
//  MyTripsCollectionViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-25.
//

import UIKit

private let reuseIdentifier = "Cell"

class MyTripsCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        let nib = UINib(nibName: "MyTripsViewCell", bundle: nil)
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "datacell")
        collectionView.register(nib, forCellWithReuseIdentifier: "datacell")
        collectionView.delegate = self
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.topViewController?.navigationItem.leftBarButtonItem?.tintColor = .black
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addTripPressed))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem?.tintColor = .black
        collectionView.reloadData()
    }
    
    @objc func addTripPressed() {
        let vc = AddTripViewController(nibName: "AddTripView", bundle: nil)
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mockUser!.trips.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "datacell", for: indexPath) as? MyTripsViewCell else {
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
}
