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
    
    typealias Observer<T> = (T) -> Void
    
    private let feedsLoader: FeedLoader
    private(set) var isLoading: Bool = false {
        didSet { onChange?(isLoading) }
    }
    
    var onChange: Observer<Bool>?
    var onLoadFeedCompletion: Observer<[FeedImage]>?
    
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
