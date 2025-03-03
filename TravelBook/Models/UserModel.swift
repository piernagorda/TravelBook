import Foundation

final class UserModel {
    var userId: String
    var email: String
    var username: String
    var name: String
    var lastname: String
    var description: String?
    var trips: [TripModel]
    var visitedCountriesAndAppearances: [String:Int] = [:]
    
    init(userId: String,
         email: String,
         username: String,
         name: String,
         lastname: String,
         description: String? = nil,
         trips: [TripModel]) {
        self.userId = userId
        self.email = email
        self.username = username
        self.name = name
        self.lastname = lastname
        self.description = description
        self.trips = trips
        self.visitedCountriesAndAppearances = self.createVisitedCountriesAndAppearancesMap()
    }
    
    public func addTrip(trip: TripModel) {
        // Append
        trips.append(trip)
        
        // Update the map
        var visitedCountriesInCurrentTrip: Set<String> = []
        
        for locations in trip.locations {
            visitedCountriesInCurrentTrip.insert(locations.countryA2code)
        }
        
        for country in visitedCountriesInCurrentTrip {
            if let count = visitedCountriesAndAppearances[country] {
                currentUser?.visitedCountriesAndAppearances[country] = count + 1
            } else {
                visitedCountriesAndAppearances[country] = 1
            }
        }
    }
    
    public func removeTripWithIndex(index: Int) {
        // Update the map
        var visitedCountriesInCurrentTrip: Set<String> = []
        for country in trips[index].locations {
            visitedCountriesInCurrentTrip.insert(country.countryA2code)
        }
        
        for country in visitedCountriesInCurrentTrip {
            if let count = visitedCountriesAndAppearances[country] {
                if count < 2 {
                    currentUser?.visitedCountriesAndAppearances.removeValue(forKey: country)
                } else {
                    currentUser?.visitedCountriesAndAppearances[country] = count - 1
                }
            }
        }
        // Deletion
        trips.remove(at: index)
    }
    
    public func removeTripWithId(id: String) {
        trips.removeAll(where: { $0.tripId == id })
    }
    
    public func toUserEntity() -> UserEntity {
        UserEntity(userId: userId,
                   email: email,
                   username: username,
                   name: name,
                   lastname: lastname,
                   trips: trips.map { $0.toTripEntity() })
    }
    
    private func createVisitedCountriesAndAppearancesMap() -> [String:Int] {
        // We want to create a dictionary of the visited countries and in how many trips they appear
        // That way, when we delete a trip, we can delete the countries in it from this map only when the count of the countries is 1
        // If its higher than 1, it means that the country has been visited in multiple trips and we can't delete it
        var countriesVisitedMap: [String:Int] = [:]
        
        for trip in trips {
            // For each trip, we get the countries from the locations array
            var countriesInTrip: [String] = []
            for country in trip.locations {
                if !(countriesInTrip.contains(country.countryA2code)) {
                    countriesVisitedMap[country.countryA2code, default: 0] += 1
                    countriesInTrip.append(country.countryA2code)
                }
            }
        }
        return countriesVisitedMap
    }
}
