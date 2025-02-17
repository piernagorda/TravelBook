import Foundation
import UIKit

final class UserEntity: Codable {
    var userId: String
    var email: String
    var username: String
    var name: String
    var lastname: String
    var description: String?
    var trips: [TripEntity]
    
    init(userId: String,
         email: String,
         username: String,
         name: String,
         lastname: String,
         description: String? = nil,
         trips: [TripEntity]) {
        self.userId = userId
        self.email = email
        self.username = username
        self.name = name
        self.lastname = lastname
        self.description = description
        self.trips = trips
    }
    
    // Function to convert UserModel to a dictionary
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "userId": userId,
            "email": email,
            "username": username,
            "name": name,
            "lastname": lastname,
            "description": description ?? ""
        ]
        
        let tripsArray = trips.map { $0.toDictionary() }
        dict["trips"] = tripsArray
        
        return dict
    }
    
    func toUserModel(arrayOfLoadedImages: [UIImage]?) -> UserModel {
        UserModel(userId: userId,
                  email: email,
                  username: username,
                  name: name,
                  lastname: lastname,
                  trips: trips.map { $0.toTripModel(loadedImage: nil) })
    }
}
