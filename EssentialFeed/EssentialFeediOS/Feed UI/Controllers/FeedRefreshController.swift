//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//
import Foundation
import UIKit
import EssentialFeed

final class FeedRefreshController: NSObject {
    
    private(set) var view: UIRefreshControl
    private let loader: FeedLoader
    
    var onRefreshComplete: (([FeedImage]) -> Void)?
    
    init(loader: FeedLoader, refreshController: UIRefreshControl) {
        self.loader = loader
        self.view = refreshController
        
        super.init()
        self.view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        self.view.beginRefreshing()
        loader.load(completion: { [weak self] result in
            if case let .success(feeds) = result {
                self?.onRefreshComplete?(feeds)
            }
            self?.view.endRefreshing()
        })
    }
}
