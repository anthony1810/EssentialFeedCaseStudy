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
}
