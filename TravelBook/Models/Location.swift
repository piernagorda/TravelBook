import UIKit

var temporaryLocations: LocationModel?

final class LocationModel: Codable {
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
}

/*
 let location = CLLocation(latitude: -22.963451, longitude: -43.198242)
 location.fetchCityAndCountry { city, country, error in
     guard let city = city, let country = country, error == nil else { return }
     print(city + ", " + country)  // Rio de Janeiro, Brazil
 }
 
 */

extension LocationModel {
    static func mock() -> Self {
        Self.init(country: "Spain",
                  city: "Madrid",
                  latitude: 40.4380986,
                  longitude: -3.8443462,
                  countryA2Code: "ES")
    }
}
