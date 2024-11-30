//
//  TripModelMocks.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 9/22/24.
//

import Foundation
import UIKit

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
                         tripImage: UIImage(named: "default-image"),
                         tripImageURL: "default-image.url",
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
                         tripImage: UIImage(named: "default-image"),
                         tripImageURL: "default-image.url",
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
                         tripImage: UIImage(named: "default-image"),
                         tripImageURL: "default-image.url",
                         description: "Test Description Three")
    }
}
