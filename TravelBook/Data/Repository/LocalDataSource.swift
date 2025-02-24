//
//  LocalDataSource.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2/22/25.
//
import CoreData
import Foundation
import UIKit

public class LocalDataSource {
    
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
        guard let title = fetchedTripCoreData.title, let tripImageURL = fetchedTripCoreData.tripImageURL else {
            return nil
        }
        
        let trip = TripModel(locations: locations,
                             year: Int(fetchedTripCoreData.year),
                             title: title,
                             tripImage: tripImage,
                             tripImageURL: tripImageURL,
                             description: fetchedTripCoreData.desc ?? "")
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
    
    private func getUserCoreDataModel(userModel: UserModel, context: NSManagedObjectContext) -> UserCoreData? {
        var newUserCoreData = UserCoreData(context: context)
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
        var newTripCoreData = TripCoreData(context: context)
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
}

/*
 @IBAction func didTapSaveDataButton() {
 
 let userModel = getUserModelTest()
 
 let appDelegate = UIApplication.shared.delegate as! AppDelegate
 let context = appDelegate.persistentContainer.viewContext
 
 var newUserCoreData = getUserCoreDataModel(userModel: userModel, context: context)
 do {
 try context.save()
 print("Saved successfully!")
 } catch {
 print("Failed to save data: \(error.localizedDescription)")
 }
 }
 
 @IBAction func didTapFetchDataButton() {
 // Fetch data from Core Data
 let appDelegate = UIApplication.shared.delegate as! AppDelegate
 let context = appDelegate.persistentContainer.viewContext
 
 let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
 
 do {
 let results = try context.fetch(fetchRequest)
 for result in results {
 // Extract User Data
 guard let userId = result.userId,
 let email = result.email,
 let name = result.name,
 let lastname = result.lastname,
 let username = result.username else {
 return
 }
 // Extract trips
 var trips: [TripModel] = []
 if let fetchedTrips = result.trips as? Set<TripCoreData>{
 for fetchedTripCoreData in fetchedTrips {
 guard let imageData = fetchedTripCoreData.tripImage,
 let tripImage = UIImage(data: imageData) else {
 print("Error converting image data to UIImage")
 return
 }
 
 // 2. Convert the locations (NSSet) to an array of LocationModel
 var locations: [LocationModel] = []
 if let fetchedLocations = fetchedTripCoreData.locations as? Set<LocationCoreData> {
 for locationCoreData in fetchedLocations {
 let location = LocationModel(country: locationCoreData.country ?? "",
 city: locationCoreData.city ?? "",
 latitude: CGFloat(locationCoreData.latitude),
 longitude: CGFloat(locationCoreData.longitude),
 countryA2Code: locationCoreData.countryA2code ?? "None")
 locations.append(location)
 }
 }
 
 // 3. Create the TripModel object
 let trip = TripModel(locations: locations,
 year: Int(fetchedTripCoreData.year),
 title: fetchedTripCoreData.title ?? "",
 tripImage: tripImage,
 tripImageURL: fetchedTripCoreData.tripImageURL ?? "",
 description: fetchedTripCoreData.desc ?? "")
 trips.append(trip)
 }
 }
 print("Successfully fetched User")
 let userModel = UserModel(userId: userId,
 email: email,
 username: username,
 name: name,
 lastname: lastname,
 description: result.desc,
 trips: trips)
 // Navigate to the next screen with the fetched trip data
 navigationController?.pushViewController(FetchDataViewController(user: userModel), animated: true)
 }
 } catch {
 print("Failed to fetch: \(error.localizedDescription)")
 }
 }
 
 }
 
 extension MainViewController {
 func getUserModelTest() -> UserModel {
 let location = LocationModel(country: "Spain", city: "Madrid", latitude: 12.5, longitude: 24, countryA2Code: "ES")
 let location2 = LocationModel(country: "Spain", city: "Barcelona", latitude: 13, longitude: 30, countryA2Code: "ES")
 let trip1 = TripModel(locations: [location, location2],
 year: 2020,
 title: "My trip",
 tripImage: UIImage(named: "javi")!,
 tripImageURL: "https://www.google.com",
 description: "My trip description")
 let location3 = LocationModel(country: "Finland", city: "Helsinki", latitude: 100, longitude: 200, countryA2Code: "FI")
 let location4 = LocationModel(country: "Finland", city: "Oulu", latitude: 300, longitude: 400, countryA2Code: "FI")
 
 let trip2 = TripModel(locations: [location3, location4],
 year: 2021,
 title: "My trip 2",
 tripImage: UIImage(named: "javi")!,
 tripImageURL: "https://www.google.com2",
 description: "My trip description 2")
 
 let userModel = UserModel(userId: "abc", email: "javier.poa@gmail.com", username: "piernagorda", name: "Javi", lastname: "Piernagorda", description: "Desc", trips: [trip1, trip2])
 return userModel
 }
 }
 
 // MARK: Methods to convert a Model to a Core Data model so that we can save it
 extension MainViewController {
 
 }
 */
