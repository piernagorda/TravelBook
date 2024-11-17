//
//  File.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 11/17/24.
//

import Foundation
import SwiftUI
import UIKit

class AchievementsViewHostingController: UIHostingController<AchievementsView> {
    // Custom initializer
    init() {
        // Initialize with the SwiftUI view and pass arguments
        let achievementsView = AchievementsView()
        super.init(rootView: achievementsView)
    }
    
    @available(*, unavailable)
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
