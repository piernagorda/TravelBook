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
        deleteTripFromFirebase(index: index) { firebaseDeleted in
            if firebaseDeleted {
                self.deleteImageFromStorage(index: index) { imageDeleted in
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

    
    private func deleteImageFromStorage(index: Int, completion: @escaping (Bool) -> Void) {
        guard let imageURL = currentUser?.trips[index].tripImageURL,
              let imagePath = getImagePath(imageURL: imageURL) else {
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

        userRef.updateData(["trips": activeUser.trips.map { $0.toTripEntity().toDictionary() }]) { error in
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
