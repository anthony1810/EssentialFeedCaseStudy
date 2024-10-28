//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 28/10/24.
//
import Foundation
import UIKit

class FakeRefreshControl: UIRefreshControl {
    
    var _isRefreshing: Bool = false
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}

extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
