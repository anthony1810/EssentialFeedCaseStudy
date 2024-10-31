//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 31/10/24.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedFetchingViewModel {
    let feeds: [FeedImage]
}

protocol FeedLoadingViewProtocol {
    func display(viewModel: FeedLoadingViewModel)
}

protocol FeedFetchingViewProtocol {
    func display(viewModel: FeedFetchingViewModel)
}

final class FeedPresenter {
    
    typealias Observer<T> = (T) -> Void
    
    private let feedsLoader: FeedLoader
    private(set) var isLoading: Bool = false {
        didSet { loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: isLoading)) }
    }
    
    var loadingView: FeedLoadingViewProtocol?
    var fetchingView: FeedFetchingViewProtocol?
    
    init(loader: FeedLoader) {
        self.feedsLoader = loader
    }
    
    func loadFeeds() {
        isLoading = true
        feedsLoader.load { [weak self] result in
            if let feeds = try? result.get() {
                self?.fetchingView?.display(viewModel: FeedFetchingViewModel(feeds: feeds))
            }
            self?.isLoading = false
        }
    }
    
}
