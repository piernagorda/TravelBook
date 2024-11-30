//
//  UserModelMocks.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 9/22/24.
//

import Foundation

extension UserModel {
    static func mock() -> UserModel {
        UserModel(userId: "4CNse5M1QyapDLTj6BobjYDThVY2",
                  email: "javier.poa@gmail.com",
                  username: "piernagorda",
                  name: "Javier",
                  lastname: "Piernagorda",
                  description: "This is my bio!",
                  trips: [.mockOne(), .mockTwo(), .mockThree()],
                  countriesVisited: ["es", "fi", "us", "ca", "fr", "it", "gr"])
    }
}

