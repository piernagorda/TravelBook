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
        
                if let localUser = self.repository.getLocalUserFromCoreData() {
                    print("Local user found. Retrieving it from CoreData")
                    currentUser = localUser
                    
                    self.activityIndicator.stopAnimating()
                    self.navigateToHomeScreen()
                } else {
                    print("Local user  NOT found. Retrieving it from Firebase")
                    self.fetchUserModelFromFirestore(userId: userID) { result in
                        switch result {
                        case .success:
                            if self.repository.saveUserToCoreData(userModel: currentUser!) {
                                print("User saved correctly to CoreData from Login")
                                self.activityIndicator.stopAnimating()
                                self.navigateToHomeScreen()
                            } else {
                                print("There was an error saving the user to CoreData from Login")
                            }
                        case .failure(let error):
                            print("Error retrieving user: \(error)")
                        }
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
    
    private func navigateToHomeScreen() {
        let tabController = TabBarController()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.pushViewController(tabController, animated: true)
    }
    
    // Fetch user data
    func fetchUserModelFromFirestore(userId: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting the user's document")
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist or data is nil"])))
                print("Error getting the user's document too")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let userEntity = try JSONDecoder().decode(UserEntity.self, from: jsonData)
                print("Decoded successfully")
                let tempUser = userEntity.toUserModel(arrayOfLoadedImages: nil)
                let dispatchGroup = DispatchGroup()
                
                print("Loading the images of the trips now")
                for trip in tempUser.trips {
                    dispatchGroup.enter()
                    self.loadImageFromURL(trip.tripImageURL) { image in
                        trip.tripImage = image
                        dispatchGroup.leave()
                    }
                }
                print("Images loaded")
                currentUser = tempUser
                dispatchGroup.notify(queue: .main) {
                    completion(.success(currentUser!))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Load image from URL
    private func loadImageFromURL(_ imageURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: imageURL) else {
            print("Error: Invalid URL")
            return
        }
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
    
    // Check if fields are complete
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
    
    // Show error
    private func showError(error: Error) {
        print(error)
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
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
