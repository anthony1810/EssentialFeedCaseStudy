//
//  UIView+Extensions.swift
//  EssentialFeed
//
//  Created by Anthony on 23/3/25.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ image: UIImage?) {
        alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
            
            guard let image else { return }
            self.image = image
        }
    }
}
