//
//  LoginViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var preloadDataButton: UIButton?
    @IBOutlet weak var loginButton: UIButton?
    @IBOutlet weak var registerButton: UIButton?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        loginButton?.layer.cornerRadius = 5
        loginButton?.layer.borderWidth = 1
        registerButton?.layer.cornerRadius = 5
        registerButton?.layer.borderWidth = 1
        preloadDataButton?.layer.cornerRadius = 5
        preloadDataButton?.layer.borderWidth = 1
    }
    
    @IBAction func loginButtonTapped() {
        // Start animating the loader
        activityIndicator.startAnimating()
        
        AuthService.shared.signIn(email: emailTextField!.text!, password: passwordTextField!.text!) { signedIn, error in
            if signedIn {
                guard let userID = Auth.auth().currentUser?.uid else {
                    return
                }
                self.fetchUserModel(userId: userID) { result in
                    switch result {
                    case .success:
                        self.activityIndicator.stopAnimating()
                        self.navigateToHomeScreen()
                    case .failure(let error):
                        print("Error retrieving user: \(error.localizedDescription)")
                    }
                }
            }
            else {
                self.showError(error: error!)
            }
        }
    }
    
    @IBAction func registerButtonTapped() {
        let registerController = RegisterViewController(nibName: "RegisterView", bundle: nil)
        self.navigationController?.pushViewController(registerController, animated: true)
    }
    
    @IBAction func preloadData() {
        self.emailTextField!.text = "javier.poa@gmail.com"
        self.passwordTextField!.text = "123456"
    }
}

extension LoginViewController {

    func fetchUserModel(userId: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist or data is nil"])))
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let userEntity = try JSONDecoder().decode(UserEntity.self, from: jsonData)
                // Setting the current user to the data retrieved
                currentUser = userEntity.toUserModel(arrayOfLoadedImages: nil)
                print(userEntity.trips[0].tripImageURL)
                print(currentUser!.trips[0].tripImageURL)
                // Initialize DispatchGroup to manage asynchronous tasks
                let dispatchGroup = DispatchGroup()
                
                for trip in currentUser!.trips {
                    // Enter the group before starting the image load
                    dispatchGroup.enter()
                    self.loadImageFromURL(trip.tripImageURL) { image in
                        trip.tripImage = image
                        // Leave the group when the image is loaded
                        dispatchGroup.leave()
                    }
                }
                // Wait for all image loading to complete before calling the completion
                dispatchGroup.notify(queue: .main) {
                    completion(.success(currentUser!))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func navigateToHomeScreen() {
        let tabController = TabBarController()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.pushViewController(tabController, animated: true)
    }
    
    private func checkFieldsComplete() -> Bool {
        if (emailTextField!.hasText && passwordTextField!.hasText ) {
            return true
        }
        else{
            let alert = UIAlertController(title: "Incomplete Fields!", message: "Please make sure to fill out all the fields", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    private func showError(error: Error) {
        print(error)
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func loadImageFromURL(_ imageURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: imageURL) else {
            print("Error: Invalid URL")
            return
        }
        // Fetch the image data asynchronously
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                print("Error: Could not convert data to image")
                completion(nil)
            }
        }.resume()
    }
}
