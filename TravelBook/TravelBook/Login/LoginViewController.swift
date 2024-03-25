//
//  LoginViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-25.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var loginButton: UIButton?
    @IBOutlet weak var registerButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonTapped() {
        let tabBarController = TabBarController()
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(tabBarController, animated: true)
    }
    
    @IBAction func registerButtonTapped() {
        let registerController = RegisterViewController(nibName: "RegisterView", bundle: nil)
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(registerController, animated: true)
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
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
