//
//  FeedLoaderPresenterAdapter.swift
//  EssentialFeed
//
//  Created by Anthony on 17/3/25.
//
import EssentialFeed
import UIKit

class FeedLoaderPresenterAdapter: FeedViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.feedLoader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feeds):
                self?.presenter?.display(feeds: feeds)
            case .failure(let error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }
}
