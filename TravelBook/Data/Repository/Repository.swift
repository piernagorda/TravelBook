//
//  Repository.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2/22/25.
//

import Foundation

public class Repository {
    
    private let localDataSource = LocalDataSource()
    
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
}
