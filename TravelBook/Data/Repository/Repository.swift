//
//  Repository.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2/22/25.
//

import Foundation

protocol RepositoryContract {
    func addTrip(trip: TripModel, completion: @escaping (Bool) -> Void)
    func getUser(userID: String, completion: @escaping (UserModel?) -> Void)
    func removeTrip(index: Int, tripId: String, completion: @escaping (Bool) -> Void)
}

public class Repository: RepositoryContract {
    
    private let localDataSource = LocalDataSource()
    private let remoteDataSource = RemoteDataSource()

    func addTrip(trip: TripModel, completion: @escaping (Bool) -> Void) {
        // 1. Remote Add
        remoteDataSource.addTripToRemote(trip: trip) { correctlyUploaded in
            if correctlyUploaded  {
                // 2. Local Add
                if self.localDataSource.addTripToCoreData(trip: trip) {
                    print("Trip added to core data, now adding to currentUser")
                    currentUser?.addTrip(trip: trip)
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func getUser(userID: String, completion: @escaping (UserModel?) -> Void) {
        if let localUser = localDataSource.getLocalUserFromCoreData() {
            completion(localUser)
        } else {
            remoteDataSource.getRemoteUserFromFirebase(userId: userID) { retrievedUser in
                guard let retrievedUser else {
                    completion(nil)
                    return
                }
                // Save the user to local. If successful, we pass it upwards. If not, nil
                if self.localDataSource.saveUserToCoreData(userModel: retrievedUser) {
                    completion(retrievedUser)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func removeTrip(index: Int, tripId: String, completion: @escaping (Bool) -> Void) {
        remoteDataSource.removeTripFromRemote(index: index) { result in
            if result {
                let localResult = self.localDataSource.removeTripFromLocal(index: index, tripId: tripId)
                completion(localResult) // Ensures the result is passed back
            } else {
                print("Failed to remove trip remotely. Local deletion skipped.")
                completion(false)
            }
        }
    }
}
