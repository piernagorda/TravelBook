//
//  RemoteDataSource.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2/22/25.
//
import FirebaseFirestore
import FirebaseStorage
import Foundation

public class RemoteDataSource {
    
    func removeTripFromRemote(index: Int, completion: @escaping (Bool) -> Void) {
        guard let tripImageURL = currentUser?.trips[index].tripImageURL else {
            completion(false)
            return
        }
        deleteTripFromFirebase(index: index) { firebaseDeleted in
            if firebaseDeleted {
                self.deleteImageFromStorage(tripImageURL: tripImageURL) { imageDeleted in
                    if !imageDeleted {
                        print("Warning: Trip deleted from Firestore, but image deletion failed.")
                    }
                    completion(true) // Even if image deletion fails, the trip is still gone.
                }
            } else {
                print("Error: Failed to delete trip from Firestore. Image deletion skipped.")
                completion(false)
            }
        }
    }
    
    func getRemoteUserFromFirebase(userId: String, completion: @escaping (UserModel?) -> Void) {
        fetchUserModelFromFirestore(userId: userId) { result in
            switch result {
            case .success:
                do {
                    let res = try result.get()
                    completion(res)
                } catch {
                    completion(nil)
                }
            case .failure(let error):
                completion(nil)
            }
        }
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
    
    func addTripToRemote(trip: TripModel, completion: @escaping (Bool) -> Void) {
        // 1 - Upload the photo to Firebase Storage
        uploadPhoto(image: (trip.tripImage)!) { imageURL in
            if let imageURL = imageURL  {
                trip.tripImageURL = imageURL
                // 2. If success -> Upload the trip to Firebase
                self.sendTripToDatabase(trip: trip) { _, error  in
                    if let error {
                        print("Error adding the trip in the DB...")
                        // self?.showError(error: error)
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } else { // If no success, we have to delete the trip from CoreData
                print("There was an error uploading the photo...")
            }
        }
    }
        
    func uploadPhoto(image: UIImage, completion: @escaping (_ imageURL: String?) -> Void) {
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
                            completion(nil)
                        } else if let url = url {
                            completion(url.absoluteString)
                        }
                    }
                }
            }
        }
    }
    
    private func sendTripToDatabase(trip: TripModel, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser!.userId)
        
        do {
            // Convert Trip struct to JSON data
            let encoder = JSONEncoder()
            let tripEntity = trip.toTripEntity()
            let jsonData = try encoder.encode(tripEntity)
            // Convert JSON data to a dictionary
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            // Make sure jsonObject is a dictionary
            guard let tripDictionary = jsonObject as? [String: Any] else {
                print("Failed to convert JSON data to dictionary.")
                completion(false, NSError(domain: "ConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON data to dictionary."]))
                return
            }
            // Update the array field by appending the new trip
            userRef.updateData([
                "trips": FieldValue.arrayUnion([tripDictionary])
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                    completion(false, error)
                } else {
                    print("Document successfully updated with new trip!")
                    completion(true, nil)
                }
            }
        } catch {
            print("Error encoding trip: \(error)")
            completion(false, error)
        }
    }
    
}

public extension RemoteDataSource {
        
    private func deleteImageFromStorage(tripImageURL: String, completion: @escaping (Bool) -> Void) {
        
        guard let imagePath = getImagePath(imageURL: tripImageURL) else {
            print("Error retrieving the image path...")
            completion(false)
            return
        }
        
        let storageRef = Storage.storage().reference().child(imagePath)
        
        storageRef.delete { error in
            if let error = error {
                print("Error deleting image from Storage: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Image successfully deleted from Storage.")
                completion(true)
            }
        }
    }

    private func deleteTripFromFirebase(index: Int, completion: @escaping (Bool) -> Void) {
        guard let activeUser = currentUser else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(activeUser.userId)
        
        var updatedTrips = activeUser.trips // This only copies the array reference
        updatedTrips.remove(at: index)
        
        userRef.updateData(["trips": updatedTrips.map { $0.toTripEntity().toDictionary() }]) { error in
            if let error = error {
                print("Error updating trips array: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Trip removed successfully!")
                completion(true)
            }
        }
    }

    private func getImagePath(imageURL: String) -> String? {
        if let encodedPath = imageURL.components(separatedBy: "/o/").last?.components(separatedBy: "?").first {
            return encodedPath.removingPercentEncoding
        }
        return nil
    }
}
