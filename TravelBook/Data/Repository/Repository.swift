//
//  Repository.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2/22/25.
//

import Foundation

public class Repository {
    
    private let localDataSource = LocalDataSource()
    
    func saveUserToCoreData(userModel: UserModel) -> Bool {
        localDataSource.saveUserToCoreData(userModel: userModel)
    }
    
    func getLocalUserFromCoreData() -> UserModel? {
        localDataSource.getLocalUserFromCoreData()
    }
}
