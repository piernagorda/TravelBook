import CoreLocation
import UIKit

final class TripModel {
    var locations: [LocationModel]
    var year: Int
    var title: String
    var description: String
    var tripId: String
    var tripImageURL: String
    var tripImage: UIImage?
    
    init(locations: [LocationModel],
         year: Int,
         title: String,
         tripImage: UIImage?,
         tripImageURL: String?,
         description: String,
         tripId: String){
        self.locations = locations
        self.year = year
        self.title = title
        self.tripImage = tripImage
        self.description = description
        self.tripId = tripId
        self.tripImageURL = tripImageURL ?? "none"
    }
    
    func toTripEntity() -> TripEntity {
        let locationsArrayEntity: [LocationEntity] = locations.map { $0.toLocationEntity() }
        return TripEntity(locations: locationsArrayEntity,
                          year: year,
                          title: title,
                          tripImageURL: tripImageURL,
                          description: description)
    }
}
