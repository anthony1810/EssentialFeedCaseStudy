//
//  UIRefreshControl+Test.swift
//  EssentialFeed
//
//  Created by Anthony on 24/2/25.
//
import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
