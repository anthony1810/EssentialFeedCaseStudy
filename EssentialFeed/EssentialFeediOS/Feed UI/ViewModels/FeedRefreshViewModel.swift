//
//  FeedRefreshViewModel.swift
//  EssentialFeed
//
//  Created by Anthony on 3/3/25.
//

import Foundation
import EssentialFeed

public final class FeedRefreshViewModel {
    enum State {
        case pending
        case loadinng
        case loaded([FeedImage])
        case failed
    }
    
    public var onChanged: ((FeedRefreshViewModel) -> Void)?
    public var onRefresh: (([FeedImage]) -> Void)?
    
    private(set) var state: State = .pending {
        didSet {
            onChanged?(self)
        }
    }
    
    public var isLoading: Bool {
        switch state {
        case .loadinng:
            return true
        default:
            return false
        }
    }
    
    public var feeds: [FeedImage]? {
        switch state {
        case .loaded(let feeds):
            return feeds
        default:
            return nil
        }
    }
    
    private let feedLoader: FeedLoader
    
    public init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        state = .loadinng
        feedLoader.load { [weak self] result in
           if let items = try? result.get() {
               self?.state = .loaded(items)
               self?.onRefresh?(items)
           } else {
               self?.state = .failed
           }
            
            self?.state = .pending
        }
    }
}

