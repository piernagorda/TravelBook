//
//  PictureTableViewCell.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-28.
//

import UIKit

class PictureTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chooseImage: UIImageView?
    @IBOutlet weak var choosePhotoButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
