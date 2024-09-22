import Foundation

final class UserModel {
    var userId: String
    var email: String
    var username: String
    var name: String
    var lastname: String
    var description: String?
    var trips: [TripModel]
    var countriesVisited: [String] = []
    
    init(userId: String,
         email: String,
         username: String,
         name: String,
         lastname: String,
         description: String? = nil,
         trips: [TripModel],
         countriesVisited: [String]?) {
        self.userId = userId
        self.email = email
        self.username = username
        self.name = name
        self.lastname = lastname
        self.description = description
        self.trips = trips
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
    
    func toUserEntity() -> UserEntity {
        UserEntity(userId: userId,
                   email: email,
                   username: username,
                   name: name,
                   lastname: lastname,
                   trips: trips.map { $0.toTripEntity() },
                   countriesVisited: countriesVisited)
    }
}
