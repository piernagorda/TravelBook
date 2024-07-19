//
//  AuthService.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2023-10-17.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {

    public static let shared = AuthService()
    
    private init() {}
    
    public func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void ) -> Void {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    public func registerUser(userRequest: RegisterUserRequest, completion: @escaping (Bool, Error?) -> Void) {
        let username = userRequest.username
        let name = userRequest.name
        let password = userRequest.password
        let birthDate = userRequest.birthDate
        let email = userRequest.email
        // TODO: Missing birthDate and Name
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
            let db = Firestore.firestore()
            db.collection("users").document(email).setData([
                "username": username,
                "email": email,
                "birthdate": birthDate,
                "name": name,
            ]) { error in
                if let error = error {
                    completion(false, error)
                    return
                }
            }
        }
    }
}
