import CoreLocation
import UIKit

final class TripEntity: Codable {
    var locations: [LocationEntity]
    var year: Int
    var title: String
    var description: String
    var tripId: String
    var tripImageURL: String
    
    init(locations: [LocationEntity],
         year: Int,
         title: String,
         tripImageURL: String,
         description: String){
        self.locations = locations
        self.year = year
        self.title = title
        self.tripImageURL = tripImageURL
        self.description = description
        self.tripId = "abc"
    }
    
    // Function to convert UserModel to a dictionary
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "year": year,
            "title": title,
            "tripImage": tripImageURL,
            "description": description,
            "tripId": tripId
        ]
        
        let locationsArray = self.locations.map { $0.toDictionary() }
        dict["locations"] = locationsArray
        
        return dict
    }
    
    func toTripModel(loadedImage: UIImage?) -> TripModel {
        TripModel(locations: locations.map { $0.toLocationModel() },
                  year: year,
                  title: title,
                  tripImage: loadedImage,
                  tripImageURL: tripImageURL,
                  description: description)
    }
}
