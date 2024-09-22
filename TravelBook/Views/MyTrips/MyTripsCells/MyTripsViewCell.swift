//
//  MyTripsViewCell.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-28.
//

import UIKit

class MyTripsViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var yearLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
    }
}
