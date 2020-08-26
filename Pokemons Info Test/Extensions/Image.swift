//
//  Image.swift
//  Pokemons Info Test
//
//  Created by Vadym on 26.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImage {
    class func drawCircle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()

        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)

        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return img
    }
}

extension UIImageView {
    func sdWebImage(id: Int, placeholderImage: UIImage) {
        let imageURL = URL(string: "https://pokeres.bastionbot.org/images/pokemon/\(id).png")!
        
        self.sd_setImage(with: imageURL, placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority) { (downloadedImage, error, cacheType, url) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
