//
//  MapViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 7/12/24.
//

import UIKit
import MapKit
import Foundation
import FirebaseStorage

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var button: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func uploadPhoto() {
        // Get the image you want to upload
        guard let image = UIImage(named: "JAVIER.jpg") else {
            print("Error: Image not found")
            return
        }
        
        // Convert the image to data
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            // Create a reference in Firebase Storage
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
            
            // Upload the image
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                } else {
                    // Get the download URL after the image is uploaded
                    imageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error getting download URL: \(error.localizedDescription)")
                        } else if let url = url {
                            print("Download URL: \(url.absoluteString)")
                            
                            // Now save the URL to Firestore
                            // self.saveImageURLToFirestore(imageURL: url.absoluteString)
                            self.loadImageFromURL(url.absoluteString)
                        }
                    }
                }
            }
        }
    }

    /*
    2. Save the Image URL in Firestore

    Once you have the download URL of the uploaded image, you can save it in Firestore under the user's document (as23912sda).

    swift

    func saveImageURLToFirestore(imageURL: String) {
        // Get a reference to Firestore
        let db = Firestore.firestore()

        // Get the user's document (replace 'as23912sda' with the actual document ID)
        let userDocRef = db.collection("users").document("as23912sda")
        
        // Update the document by adding the image URL (e.g., under the field 'profileImageUrl')
        userDocRef.updateData([
            "profileImageUrl": imageURL
        ]) { error in
            if let error = error {
                print("Error updating Firestore: \(error.localizedDescription)")
            } else {
                print("Image URL successfully saved to Firestore")
            }
        }
    }
     */
    
    func loadImageFromURL(_ imageURL: String) {
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
                DispatchQueue.main.async {
                    // Ensure the navigationController exists before pushing
                    if let navigationController = self.navigationController {
                        let testController = TestViewController(nibName: "TestView", bundle: nil)
                        testController.imagee = image
                        print(image)
                        navigationController.pushViewController(testController, animated: true)
                    } else {
                        print("Error: Navigation controller is nil")
                    }
                }
            } else {
                print("Error: Could not convert data to image")
            }
        }.resume()
    }

}
