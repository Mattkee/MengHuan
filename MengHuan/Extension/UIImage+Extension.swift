//
//  UIImage+Extension.swift
//  MengHuan
//
//  Created by Lei et Matthieu on 09/04/2019.
//  Copyright © 2019 Mattkee. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Image Management
extension UIImage {
    class func displayImage(_ url: String) -> UIImage {

        guard let imageUrl = URL(string: url) else {
            return UIImage(imageLiteralResourceName: "Virtuel reality")
        }
        guard let imageData = try? Data(contentsOf: imageUrl) else {
            return UIImage(imageLiteralResourceName: "Virtuel reality")
        }
        guard let image = UIImage(data: imageData) else {
            return UIImage(imageLiteralResourceName: "Virtuel reality")
        }
        return image
    }
}
