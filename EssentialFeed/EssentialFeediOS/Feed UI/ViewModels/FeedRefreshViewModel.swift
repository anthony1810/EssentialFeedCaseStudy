//
//  FeedRefreshViewModel.swift
//  EssentialFeed
//
//  Created by Anthony on 3/3/25.
//

import Foundation
import EssentialFeed

public final class FeedRefreshViewModel {
    typealias Observer<T> = (T) -> Void
    
    var onLoadingFeed: Observer<Bool>?
    var onLoadedFeed: Observer<[FeedImage]>?

    private let feedLoader: FeedLoader
    
    public init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        onLoadingFeed?(true)
        feedLoader.load { [weak self] result in
            if let items = try? result.get() {
                self?.onLoadedFeed?(items)
            }
            self?.onLoadingFeed?(false)
        }
    }
}

