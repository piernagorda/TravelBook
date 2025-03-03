import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var preloadDataButton: UIButton?
    @IBOutlet weak var loginButton: UIButton?
    @IBOutlet weak var registerButton: UIButton?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let repository = Repository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        
        // Set the "Done" key for both text fields
        emailTextField?.returnKeyType = .done
        emailTextField?.delegate = self
        
        passwordTextField?.returnKeyType = .done
        passwordTextField?.delegate = self
        
        loginButton?.layer.cornerRadius = 5
        loginButton?.layer.borderWidth = 1
        
        registerButton?.layer.cornerRadius = 5
        registerButton?.layer.borderWidth = 1
        
        preloadDataButton?.layer.cornerRadius = 5
        preloadDataButton?.layer.borderWidth = 1

        self.hideKeyboardWhenTappedAround() // Dismiss keyboard when tapping outside of it
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func loginButtonTapped() {
        
        activityIndicator.startAnimating()
        
        AuthService.shared.signIn(email: emailTextField!.text!, password: passwordTextField!.text!) { signedIn, error in
            if signedIn {
                guard let userID = Auth.auth().currentUser?.uid else {
                    return
                }
                let repository = Repository()
                repository.getUser(userID: userID) { user in
                    if user != nil {
                        currentUser = user
                        self.navigateToHomeScreen()
                    } else {
                        self.showError()
                    }
                    self.activityIndicator.stopAnimating()
                }
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
    
    private func showError() {
        let alert = UIAlertController(title: "Error", message: "There was an error", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Dismiss keyboard when "Done" is tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Resign the first responder to dismiss the keyboard
        textField.resignFirstResponder()
        return true
    }
}
