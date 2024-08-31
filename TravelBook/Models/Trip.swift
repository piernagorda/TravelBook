import CoreLocation
import UIKit

final class TripModel: Codable {
    var locations: [LocationModel]
    var year: Int
    var title: String
    var tripImage: String?
    var description: String
    var tripId: String
    
    init(locations: [LocationModel],
         year: Int,
         title: String,
         tripImage: String = "default-image",
         description: String){
        self.locations = locations
        self.year = year
        self.title = title
        self.tripImage = tripImage
        self.description = description
        self.tripId = "abc"
    }
    
    // Function to convert UserModel to a dictionary
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "year": year,
            "title": title,
            "tripImage": tripImage ?? "",
            "description": description,
            "tripId": tripId
        ]
        
        let locationsArray = self.locations.map { $0.toDictionary() }
        dict["locations"] = locationsArray
        
        return dict
    }
}

extension TripModel {
    static func mockOne() -> TripModel {
        let bcn = LocationModel(country: "Spain",
                                city: "Barcelona",
                                latitude: 41.3927673,
                                longitude: 2.057788,
                                countryA2Code: "es")
        return TripModel(locations: [.mock(), bcn],
                         year: 2022,
                         title: "Test Trip",
                         tripImage: "default-image",
                         description: "Test Description")
    }
    
    static func mockTwo() -> TripModel {
        let helsinki = LocationModel(country: "Finland",
                                     city: "Helsinki",
                                     latitude: 60.1097541,
                                     longitude: 24.6890579,
                                     countryA2Code: "fi")
        return TripModel(locations: [.mock(), helsinki],
                         year: 2023,
                         title: "Test Trip",
                         tripImage: "default-image2",
                         description: "Test Description Two")
    }
    
    static func mockThree() -> TripModel {
        let thessa = LocationModel(country: "Greece",
                                   city: "Thessaloniki",
                                   latitude: 40.6211852,
                                   longitude: 22.9048277,
                                   countryA2Code: "gr")
        let turkey = LocationModel(country: "Turkey",
                                   city: "Capadoccia",
                                   latitude: 38.3694845,
                                   longitude: 33.7451519,
                                   countryA2Code: "tr")
        let sophia = LocationModel(country: "Bulgaria",
                                   city: "Sophia",
                                   latitude: 42.6954025,
                                   longitude: 23.2413747,
                                   countryA2Code: "bg")
        return TripModel(locations: [.mock(), thessa, turkey, sophia],
                         year: 2020,
                         title: "Test Trip",
                         tripImage: "default-image3",
                         description: "Test Description Three")
    }
}
