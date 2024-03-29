//
//  NameAndDescriptionTableViewCell.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 2024-03-28.
//

import UIKit

class NameAndDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView?
    @IBOutlet weak var textField: UITextField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
