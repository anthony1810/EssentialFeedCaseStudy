//
//  FeedRefreshViewModel.swift
//  EssentialFeed
//
//  Created by Anthony on 3/3/25.
//

import Foundation
import EssentialFeed

public final class FeedRefreshViewModel {
    public var onChanged: ((FeedRefreshViewModel) -> Void)?
    public var onLoadedFeed: (([FeedImage]) -> Void)?
    
    public var isLoading: Bool = false {
        didSet {
            onChanged?(self)
        }
    }

    private let feedLoader: FeedLoader
    
    public init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
           if let items = try? result.get() {
               self?.onLoadedFeed?(items)
           }
            
            self?.isLoading = false
        }
    }
}

