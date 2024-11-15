//
//  ImageResizer.swift
//  TravelBook
//
//  Created by Javier Piernagorda Olivé on 11/15/24.
//

import Foundation
import UIKit

func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    return renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: targetSize))
    }
}
