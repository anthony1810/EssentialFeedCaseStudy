//
//  FakeRefreshControl.swift
//  EssentialFeed
//
//  Created by Anthony on 24/2/25.
//
import UIKit

class FakeUIRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
