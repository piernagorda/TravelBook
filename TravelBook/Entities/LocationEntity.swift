import UIKit

final class LocationEntity: Codable {
    var country: String
    var city: String
    var latitude: CGFloat
    var longitude: CGFloat
    var countryA2code: String
    
    init(country: String, city: String, latitude: CGFloat, longitude: CGFloat, countryA2Code: String) {
        self.country = country
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.countryA2code = countryA2Code
    }
    
    // Function to convert UserModel to a dictionary
    func toDictionary() -> [String: Any] {
        return [
            "country": country,
            "city": city,
            "latitude": latitude,
            "longitude": longitude,
            "countryA2code" : countryA2code
        ]
    }
    
    func toLocationModel() -> LocationModel {
        LocationModel(country: country,
                      city: city,
                      latitude: latitude,
                      longitude: longitude,
                      countryA2Code: countryA2code)
    }
}
