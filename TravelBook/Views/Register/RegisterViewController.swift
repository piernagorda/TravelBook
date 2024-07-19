//
//  RegisterViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var passwordRepeatTextField: UITextField?
    @IBOutlet weak var usernameTextField: UITextField?
    @IBOutlet weak var fullNameTextField: UITextField?

    @IBOutlet weak var registerButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func registerButtonPressed() {
        view.endEditing(true)
        if (fullNameTextField!.hasText && emailTextField!.hasText && usernameTextField!.hasText && passwordTextField!.hasText && passwordRepeatTextField!.hasText && passwordTextField!.text == passwordRepeatTextField!.text){
            // Request Data
            let userData = RegisterUserRequest(email: emailTextField!.text!,
                                              password: passwordTextField!.text!,
                                              name: emailTextField!.text!,
                                              username: usernameTextField!.text!,
                                              birthDate: Date())
                        
            AuthService.shared.registerUser(userRequest: userData, completion: { wasRegistered, error in
                if let error = error {
                    print(error.localizedDescription)
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
                self.navigateToHomeScreen(userData)
            })
        }
        else{
            manageError()
        }
    }
    
    private func manageError() {
        let alert = UIAlertController(title: "Incomplete Fields!", message: "Please make sure to fill out all the fields", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    private func navigateToHomeScreen(_ userData: RegisterUserRequest) {
        mockUser?.name = userData.name
        mockUser?.email = userData.email
        mockUser?.username = userData.username
        
        let tabController = TabBarController()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isHidden = false
        navigationController?.pushViewController(tabController, animated: true)
    }
}
