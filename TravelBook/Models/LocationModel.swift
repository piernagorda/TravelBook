import UIKit

var temporaryLocations: LocationModel?

final class LocationModel: Codable, Hashable, Equatable {
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
    
    func toLocationEntity() -> LocationEntity {
        LocationEntity(country: country,
                       city: city,
                       latitude: latitude,
                       longitude: longitude,
                       countryA2Code: countryA2code)
    }
    
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        return lhs.country == rhs.country &&
               lhs.city == rhs.city &&
               lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude &&
               lhs.countryA2code == rhs.countryA2code
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(country)
        hasher.combine(city)
        hasher.combine(latitude)
        hasher.combine(longitude)
        hasher.combine(countryA2code)
    }
}
