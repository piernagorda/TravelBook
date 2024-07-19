import Foundation

final class UserModel {
    
    var email: String
    var password: String
    var username: String
    var name: String
    var lastname: String
    var description: String?
    var trips: [TripModel]
    var countriesVisited: [String] = []
    
    init(email: String,
         password: String,
         username: String,
         name: String,
         lastname: String,
         description: String? = nil,
         countriesVisited: [String]?) {
        self.email = email
        self.password = password
        self.username = username
        self.name = name
        self.lastname = lastname
        self.description = description
        self.trips = []
        self.countriesVisited = countriesVisited ?? []
    }
    
    public func addTrip(trip: TripModel) {
        trips.append(trip)
    }
    
    public func removeTripWithIndex(index: Int) {
        trips.remove(at: index)
    }
    
    public func removeTripWithId(id: String) {
        trips.removeAll(where: { $0.tripId == id })
    }
}

extension UserModel {
    static func mock() -> UserModel {
        UserModel(email: "javier.poa@gmail.com",
                  password: "123456",
                  username: "piernagorda",
                  name: "Javier",
                  lastname: "Piernagorda",
                  description: "This is my bio!",
                  countriesVisited: ["ES", "FI", "US", "CA", "FR", "IT", "GR"])
    }
}
