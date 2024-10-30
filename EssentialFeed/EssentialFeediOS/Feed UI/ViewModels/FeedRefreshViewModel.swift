//
//  FeedRefreshViewModel.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//
import Foundation
import UIKit
import EssentialFeed

final class FeedRefreshViewModel {
    private let feedsLoader: FeedLoader
    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    var onChange: ((FeedRefreshViewModel) -> Void)?
    var onLoadFeedCompletion: (([FeedImage]) -> Void)?
    
    init(loader: FeedLoader) {
        self.feedsLoader = loader
    }
    
    func loadFeeds() {
        isLoading = true
        feedsLoader.load { [weak self] result in
            if let feeds = try? result.get() {
                self?.onLoadFeedCompletion?(feeds)
            }
            self?.isLoading = false
        }
    }
    
}
