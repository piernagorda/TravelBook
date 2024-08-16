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
        AuthService.shared.signIn(email: emailTextField!.text!, password: passwordTextField!.text!) { signedIn, error in
            if signedIn {
                self.fetchUserModel(userId: "as23912sda") { result in
                    switch result {
                    case .success:
                        print("User retrieved successfully")
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
                let userModel = try JSONDecoder().decode(UserModel.self, from: jsonData)
                // Setting the current user to the data retrieved
                currentUser = userModel
                completion(.success(userModel))
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
}
