import Foundation

final class UserModel: Codable {
    var userId: String
    var email: String
    var password: String
    var username: String
    var name: String
    var lastname: String
    var description: String?
    var trips: [TripModel]
    var countriesVisited: [String] = []
    
    init(userId: String,
         email: String,
         password: String,
         username: String,
         name: String,
         lastname: String,
         description: String? = nil,
         trips: [TripModel],
         countriesVisited: [String]?) {
        self.userId = userId
        self.email = email
        self.password = password
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
    
    // Function to convert UserModel to a dictionary
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "userId": userId,
            "email": email,
            "password": password,
            "username": username,
            "name": name,
            "lastname": lastname,
            "description": description ?? "",
            "countriesVisited": countriesVisited
        ]
        
        let tripsArray = trips.map { $0.toDictionary() }
        dict["trips"] = tripsArray
        
        return dict
    }
}

extension UserModel {
    static func mock() -> UserModel {
        UserModel(userId: "as23912sda",
                  email: "javier.poa@gmail.com",
                  password: "123456",
                  username: "piernagorda",
                  name: "Javier",
                  lastname: "Piernagorda",
                  description: "This is my bio!",
                  trips: [.mockOne(), .mockTwo(), .mockThree()],
                  countriesVisited: ["es", "fi", "us", "ca", "fr", "it", "gr"])
    }
}
