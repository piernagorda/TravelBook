//
//  LocationModelMocks.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 9/22/24.
//

import Foundation

extension LocationModel {
    static func mock() -> Self {
        Self.init(country: "Spain",
                  city: "Madrid",
                  latitude: 40.4380986,
                  longitude: -3.8443462,
                  countryA2Code: "ES")
    }
}
