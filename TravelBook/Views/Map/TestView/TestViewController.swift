//
//  TestViewController.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 9/12/24.
//

import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    
    var imagee: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.image?.image = self.imagee
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        image.layer.masksToBounds = true
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.borderWidth = 2
    }
}
