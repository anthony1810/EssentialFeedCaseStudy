//
//  UIImage+Extensions.swift
//  EssentialFeediOSTests2
//
//  Created by Anthony on 30/11/24.
//

import Foundation
import UIKit

extension UIImage {
     static func make(withColor color: UIColor) -> UIImage {
         let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
         UIGraphicsBeginImageContext(rect.size)
         let context = UIGraphicsGetCurrentContext()!
         context.setFillColor(color.cgColor)
         context.fill(rect)
         let img = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         return img!
     }
 }
