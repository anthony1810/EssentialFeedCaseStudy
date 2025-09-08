//
//  UIView+Container.swift
//  EssentialFeed
//
//  Created by Anthony on 16/8/25.
//

import UIKit

extension UIButton {
    public func makeContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(self)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.topAnchor.constraint(equalTo: container.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        return container
    }
}
