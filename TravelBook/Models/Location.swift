import UIKit

var temporaryLocations: LocationModel?

final class LocationModel {
    var country: String
    var city: String
    var latitude: CGFloat
    var longitude: CGFloat
    
    init(country: String, city: String, latitude: CGFloat, longitude: CGFloat) {
        self.country = country
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension LocationModel {
    static func mock() -> Self {
        Self.init(country: "Spain",
                  city: "Madrid",
                  latitude: 40.4380986,
                  longitude: -3.8443462)
    }
}
