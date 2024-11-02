//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 31/10/24.
//

import Foundation
import EssentialFeed

protocol FeedLoadingViewProtocol {
    func display(viewModel: FeedLoadingViewModel)
}

protocol FeedFetchingViewProtocol {
    func display(viewModel: FeedFetchingViewModel)
}

final class FeedPresenter {
    
    typealias Observer<T> = (T) -> Void
    
    private(set) var isLoading: Bool = false {
        didSet { loadingView.display(viewModel: FeedLoadingViewModel(isLoading: isLoading)) }
    }
    
    var loadingView: FeedLoadingViewProtocol
    var fetchingView: FeedFetchingViewProtocol
    
    init(loadingView: FeedLoadingViewProtocol, fetchingView: FeedFetchingViewProtocol) {
        self.loadingView = loadingView
        self.fetchingView = fetchingView
    }
    
    func startLoading() {
        isLoading = true
    }
    
    func finishLoadingSuccessfully(feeds: [FeedImage]) {
        fetchingView.display(viewModel: FeedFetchingViewModel(feeds: feeds))
        isLoading = false
    }
    
    func finishLoadingFailure(error: Error) {
        isLoading = false
    }
    
}
