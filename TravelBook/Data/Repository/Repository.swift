//
//  Repository.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2/22/25.
//

import Foundation

public class Repository {
    
    private let localDataSource = LocalDataSource()
    private let remoteDataSource = RemoteDataSource()
    
    // MARK: Save data
    func saveUserToCoreData(userModel: UserModel) -> Bool {
        localDataSource.saveUserToCoreData(userModel: userModel)
    }
    
    func addTripToCoreData(trip: TripModel) -> Bool {
        localDataSource.addTripToCoreData(trip: trip)
    }
    
    // MARK: Retrieve data
    func getLocalUserFromCoreData() -> UserModel? {
        localDataSource.getLocalUserFromCoreData()
    }
    
    // MARK: Delete data
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
