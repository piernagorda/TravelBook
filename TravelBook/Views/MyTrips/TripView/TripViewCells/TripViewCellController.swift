//
//  TripViewCell.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 8/31/24.
//

import UIKit

class TripViewCellController: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var city: UILabel?
    @IBOutlet weak var country: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.borderWidth = 1
        image.layer.cornerRadius = 5.0
        image.layer.masksToBounds = true
    }

}
