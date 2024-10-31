//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 31/10/24.
//

import Foundation
import UIKit
import EssentialFeed

protocol FeedLoadingViewProtocol: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedFetchingViewProtocol {
    func display(feeds: [FeedImage])
}

final class FeedPresenter {
    
    typealias Observer<T> = (T) -> Void
    
    private let feedsLoader: FeedLoader
    private(set) var isLoading: Bool = false {
        didSet { loadingView?.display(isLoading: isLoading) }
    }
    
    weak var loadingView: FeedLoadingViewProtocol?
    var fetchingView: FeedFetchingViewProtocol?
    
    init(loader: FeedLoader) {
        self.feedsLoader = loader
    }
    
    func loadFeeds() {
        isLoading = true
        feedsLoader.load { [weak self] result in
            if let feeds = try? result.get() {
                self?.fetchingView?.display(feeds: feeds)
            }
            self?.isLoading = false
        }
    }
    
}
