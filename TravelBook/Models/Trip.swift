import UIKit

final class TripModel {
    var locations: [LocationModel]
    var year: Int
    var title: String
    var tripImage: UIImage?
    var description: String
    var tripId: String
    
    init(locations: [LocationModel],
         year: Int,
         title: String,
         tripImage: UIImage? = nil,
         description: String){
        self.locations = locations
        self.year = year
        self.title = title
        self.tripImage = tripImage
        self.description = description
        self.tripId = "abc"
    }
}

extension TripModel {
    static func mockOne() -> TripModel {
        let bcn = LocationModel(country: "Spain", city: "Barcelona", latitude: 41.3927673, longitude: 2.057788)
        return TripModel(locations: [.mock(), bcn],
                         year: 2022,
                         title: "Test Trip",
                         tripImage: UIImage(named: "default-image"),
                         description: "Test Description")
    }
    
    static func mockTwo() -> TripModel {
        let helsinki = LocationModel(country: "Finland", city: "Helsinki", latitude: 60.1097541, longitude: 24.6890579)
        return TripModel(locations: [.mock(), helsinki],
                         year: 2023,
                         title: "Test Trip",
                         tripImage: UIImage(named: "default-image2"),
                         description: "Test Description Two")
    }
    
    static func mockThree() -> TripModel {
        let thessa = LocationModel(country: "Greece", city: "Thessaloniki", latitude: 40.6211852, longitude: 22.9048277)
        return TripModel(locations: [.mock(), thessa],
                         year: 2020,
                         title: "Test Trip",
                         tripImage: UIImage(named: "default-image3"),
                         description: "Test Description Three")
    }
}
