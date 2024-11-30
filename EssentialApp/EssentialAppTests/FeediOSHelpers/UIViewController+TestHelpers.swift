//
//  UIViewController+TestHelpers.swift
//  EssentialApp
//
//  Created by Anthony on 30/11/24.
//

import UIKit

extension UIView {
    
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.main.run(until: Date())
    }
    
}
