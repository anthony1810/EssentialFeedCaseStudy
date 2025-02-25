//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 25/2/25.
//

import UIKit

import EssentialFeed

public final class FeedRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    private let feedLoader: FeedLoader
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    public init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    @objc
    func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            if case let .success(items) = result {
                self?.onRefresh?(items)
            }
            self?.view.endRefreshing()
        }
    }
}
