//
//  LocalDataSource.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2/22/25.
//
import CoreData
import Foundation
import UIKit

protocol LocalDataSourceProtocol {
    func getLocalUserFromCoreData() -> UserModel?
    func saveUserToCoreData(userModel: UserModel) -> Bool
    func addTripToCoreData(trip: TripModel) -> Bool
    func deleteTripFromCoreData(index: Int, tripId: String) -> Bool
}

public class LocalDataSource: LocalDataSourceProtocol {
    
    // -------------------------------
    // MARK: FETCH USER FROM CORE DATA
    // -------------------------------
    func getLocalUserFromCoreData() -> UserModel? {
        // Fetch data from Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        var userModel: UserModel?
        
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                // 1. Extract User Data
                guard let userId = result.userId,
                      let email = result.email,
                      let name = result.name,
                      let lastname = result.lastname,
                      let username = result.username else {
                    return nil
                }
                // 2. Extract trips
                var trips: [TripModel] = []
                if let fetchedTrips = result.trips as? Set<TripCoreData>{
                    for fetchedTripCoreData in fetchedTrips {
                        if let tripToAdd = getTripFromSet(fetchedTripCoreData: fetchedTripCoreData) {
                            trips.append(tripToAdd)
                        }
                    }
                }
                // 3. Create user
                userModel = UserModel(userId: userId,
                                      email: email,
                                      username: username,
                                      name: name,
                                      lastname: lastname,
                                      description: result.desc,
                                      trips: trips)
                print("Successfully fetched User")
            }
        } catch {
            print("Failed to fetch: \(error.localizedDescription)")
        }
        return userModel
    }
    
    private func getTripFromSet(fetchedTripCoreData: TripCoreData) -> TripModel? {
        // 1. Convert the binary data to image
        guard let imageData = fetchedTripCoreData.tripImage,
              let tripImage = UIImage(data: imageData) else {
            print("Error converting image data to UIImage")
            return nil
        }
        
        // 2. Convert the locations (NSSet) to an array of LocationModel
        var locations: [LocationModel] = []
        if let fetchedLocations = fetchedTripCoreData.locations as? Set<LocationCoreData> {
            if let locationsArray = getLocationsFromSet(fetchedLocations: fetchedLocations) {
                locations = locationsArray
            }
        }

        // 3. Create the TripModel object
        guard let title = fetchedTripCoreData.title,
              let tripImageURL = fetchedTripCoreData.tripImageURL,
              let tripId = fetchedTripCoreData.tripId else {
            return nil
        }
        
        let trip = TripModel(locations: locations,
                             year: Int(fetchedTripCoreData.year),
                             title: title,
                             tripImage: tripImage,
                             tripImageURL: tripImageURL,
                             description: fetchedTripCoreData.desc ?? "",
                             tripId: tripId)
        return trip
    }
    
    private func getLocationsFromSet(fetchedLocations: Set<LocationCoreData>) -> [LocationModel]? {
        var locations: [LocationModel] = []
        
        for locationCoreData in fetchedLocations {
            
            guard let country = locationCoreData.country,
                  let city = locationCoreData.city,
                  let countryA2Code = locationCoreData.countryA2code else {
                // If one location is not valid we return nil for the whole array
                return nil
            }
            let latitude = CGFloat(locationCoreData.latitude)
            let longitude = CGFloat(locationCoreData.longitude)
            
            let location = LocationModel(country: country,
                                         city: city,
                                         latitude: latitude,
                                         longitude: longitude,
                                         countryA2Code: countryA2Code)
            locations.append(location)
        }
        return locations
    }
    
    // -------------------------------
    // MARK: SAVE USER TO CORE DATA
    // -------------------------------
    func saveUserToCoreData(userModel: UserModel) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        var newUserCoreData = getUserCoreDataModel(userModel: userModel, context: context)
        do {
            try context.save()
            print("Saved successfully!")
            return true
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
            return false
        }
    }
    
    func addTripToCoreData(trip: TripModel) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Fetch the existing user from Core Data
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", currentUser!.userId) // Filter for the current user
        
        do {
            let results = try context.fetch(fetchRequest)
            guard let userCoreData = results.first else {
                print("User not found in Core Data")
                return false
            }
            
            // Convert the new trip into CoreData format
            guard let newTripCoreData = getTripCoreDataModel(tripModel: trip, context: context) else {
                return false
            }
            
            // Add the new trip to the user's trips
            var existingTrips = userCoreData.trips as? Set<TripCoreData> ?? []
            existingTrips.insert(newTripCoreData)
            userCoreData.trips = NSSet(set: existingTrips)
            
            try context.save()
            print("Trip added successfully to Core Data")
            return true
        } catch {
            print("Failed to update Core Data: \(error.localizedDescription)")
            return false
        }
    }
    
    private func getUserCoreDataModel(userModel: UserModel, context: NSManagedObjectContext) -> UserCoreData? {
        let newUserCoreData = UserCoreData(context: context)
        newUserCoreData.userId = userModel.userId
        newUserCoreData.email = userModel.email
        newUserCoreData.username = userModel.username
        newUserCoreData.name = userModel.name
        newUserCoreData.lastname = userModel.lastname
        newUserCoreData.desc = userModel.description
        
        var tripsCoreDataArray: [TripCoreData] = []
        for trip in userModel.trips {
            guard let tripCoreData = getTripCoreDataModel(tripModel: trip, context: context) else {
                return nil
            }
            tripsCoreDataArray.append(tripCoreData)
        }
        newUserCoreData.trips = NSSet(array: tripsCoreDataArray)
        return newUserCoreData
    }
    
    
    private func getTripCoreDataModel(tripModel: TripModel, context: NSManagedObjectContext) -> TripCoreData? {
        // Create a new TripCoreData object
        let newTripCoreData = TripCoreData(context: context)
        newTripCoreData.year = Int32(tripModel.year)
        newTripCoreData.title = tripModel.title
        newTripCoreData.desc = tripModel.description
        newTripCoreData.tripId = tripModel.tripId
        newTripCoreData.tripImageURL = tripModel.tripImageURL
        
        // Create LocationCoreData objects for each LocationModel
        var locationsCoreData: Set<LocationCoreData> = []  // Use a Set for the to-many relationship
        
        for locationModel in tripModel.locations {
            let locationCoreData = getLocationCoreDataModel(locationModel: locationModel, context: context)
            // Add the LocationCoreData object to the locations set
            locationsCoreData.insert(locationCoreData)
        }
        
        // Convert the Set to an NSSet before assigning to the relationship
        newTripCoreData.locations = NSSet(set: locationsCoreData)
        
        // Convert UIImage to Data and save it
        guard let imageData = tripModel.tripImage?.jpegData(compressionQuality: 1.0) else {
            print("Error converting image to data")
            return nil
        }
        newTripCoreData.tripImage = imageData
        return newTripCoreData
    }
    
    private func getLocationCoreDataModel(locationModel: LocationModel, context: NSManagedObjectContext) -> LocationCoreData {
        let locationCoreData = LocationCoreData(context: context)
        locationCoreData.latitude = Float(locationModel.latitude)
        locationCoreData.longitude = Float(locationModel.longitude)
        locationCoreData.country = locationModel.country
        locationCoreData.city = locationModel.city
        locationCoreData.countryA2code = locationModel.countryA2code
        return locationCoreData
    }
    
    // --------------------------------
    // MARK: DELETE TRIP FROM CORE DATA
    // --------------------------------
    
    func deleteTripFromCoreData(index: Int, tripId: String) -> Bool {
        guard let currentUser else {
            print("No active user found.")
            return false
        }

        guard index >= 0, index < currentUser.trips.count else {
            print("Invalid trip index: \(index)")
            return false
        }

        // Try deleting from Core Data first
        if deleteTripFromCoreData(tripId: tripId) {
            print("Trip successfully removed from local storage.")
            return true
        } else {
            print("Core Data deletion failed. Local trip removal aborted.")
            return false
        }
    }

    
    private func deleteTripFromCoreData(tripId: String) -> Bool {
        guard let currentUser = currentUser else {
            print("No active user found.")
            return false
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", currentUser.userId)

        do {
            let results = try context.fetch(fetchRequest)
            guard let userCoreData = results.first else {
                print("User not found in Core Data")
                return false
            }

            guard let existingTrips = userCoreData.trips as? Set<TripCoreData> else {
                print("No trips found for the user")
                return false
            }

            if let tripToDelete = existingTrips.first(where: { $0.tripId == tripId }) {
                context.delete(tripToDelete)
                try context.save()
                print("Trip removed successfully from Core Data")
                return true
            } else {
                print("Trip not found in Core Data")
                return false
            }
        } catch {
            print("Failed to delete trip from Core Data: \(error.localizedDescription)")
            return false
        }
    }
}
