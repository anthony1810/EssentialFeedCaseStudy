//
//  UIImageView+Extensions.swift
//  EssentialFeed
//
//  Created by Anthony on 2/11/24.
//

import UIKit

extension UIImageView {
    func setImage(_ newImage: UIImage?) {
        image = newImage
        
        guard let newImage else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
