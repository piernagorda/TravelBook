//
//  ProfileViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-25.
//
import FirebaseAuth
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
        // rectangle.portrait.and.arrow.right
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                                                                                                     style: .plain,
                                                                                                     target: self,
                                                                                                     action: #selector(logoutMessage))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem?.tintColor = .black
        super.navigationController?.navigationBar.isHidden = false
    }
    
    func setUpProfileView() {
        name?.text = currentUser?.name
        username?.text = "@"+currentUser!.username
        biography?.text = currentUser?.description
        let nib = UINib(nibName: "AchievementsViewCell", bundle: nil)
        self.achievementsCollectionView!.register(nib, forCellWithReuseIdentifier: "datacell2")
    }
    
    @objc func logoutMessage() {
        let alert = UIAlertController(title: "Log Out", message: "You're going to log out. Are you sure?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let logoutAction = UIAlertAction(title: "OK", style: .default) {_ in
            self.logout()
        }
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        self.present(alert, animated: true)
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Logged out")
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { currentUser!.countriesVisited.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "datacell2", for: indexPath) as? AchievementsViewCell else {
            return UICollectionViewCell()
        }
        cell.achievementImage?.image = UIImage(named: currentUser!.countriesVisited[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {    // add the code here to perform action on the cell
        // let cell = collectionView.cellForItem(at: indexPath) as? CustomCellClass
    }
    
}
