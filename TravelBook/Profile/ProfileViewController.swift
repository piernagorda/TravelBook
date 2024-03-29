//
//  ProfileViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-25.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var username: UILabel?
    @IBOutlet weak var biography: UILabel?
    @IBOutlet weak var profilePicture: UIImageView?
    @IBOutlet weak var backgroundPicture: UIImageView?
    @IBOutlet weak var achievementsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        setUpProfileView()
        super.viewDidLoad()
        achievementsCollectionView.dataSource = self
        achievementsCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = nil
    }
    
    func setUpProfileView() {
        name?.text = mockUser?.name
        username?.text = "@"+mockUser!.username
        biography?.text = mockUser?.description
        let nib = UINib(nibName: "AchievementsViewCell", bundle: nil)
        self.achievementsCollectionView!.register(nib, forCellWithReuseIdentifier: "datacell2")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mockUser!.countriesVisited.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "datacell2", for: indexPath) as? AchievementsViewCell else {
            return UICollectionViewCell()
        }
        cell.achievementImage?.image = UIImage(named: mockUser!.countriesVisited[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {    // add the code here to perform action on the cell
        // let cell = collectionView.cellForItem(at: indexPath) as? CustomCellClass
    }
    
}
