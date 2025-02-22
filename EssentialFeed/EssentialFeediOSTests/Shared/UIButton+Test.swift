//
//  UIButton+Test.swift
//  EssentialFeed
//
//  Created by Anthony on 22/2/25.
//
import UIKit

extension UIButton {
    func simulateButtonTapped() {
        simulate(event: .touchUpInside)
    }
    
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
