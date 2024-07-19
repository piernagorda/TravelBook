//
//  LoginViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-25.
//

import Foundation
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
        mockUser = .mock()
        mockUser?.addTrip(trip: .mockOne())
        mockUser?.addTrip(trip: .mockTwo())
        mockUser?.addTrip(trip: .mockThree())
    }
    
    @IBAction func loginButtonTapped() {
        AuthService.shared.signIn(email: emailTextField!.text!, password: passwordTextField!.text!) { signedIn, error in
            if signedIn {
                self.navigateToHomeScreen()
            }
            else {
                self.showError(error: error!)
            }
        }
    }
    
    @IBAction func registerButtonTapped() {
        let registerController = RegisterViewController(nibName: "RegisterView", bundle: nil)
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(registerController, animated: true)
    }
    
    @IBAction func preloadData() {
        self.emailTextField!.text = mockUser?.email
        self.passwordTextField!.text = mockUser?.password
    }
}

extension LoginViewController {
    private func navigateToHomeScreen() {
        let tabController = TabBarController()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isHidden = false
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
