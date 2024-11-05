//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 31/10/24.
//

import Foundation
import EssentialFeed

struct FeedErrorViewModel {
    let message: String
}

protocol FeedLoadingViewProtocol {
    func display(viewModel: FeedLoadingViewModel)
}

protocol FeedFetchingViewProtocol {
    func display(viewModel: FeedFetchingViewModel)
}

protocol FeedErrorViewProtocol {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    
    typealias Observer<T> = (T) -> Void
    
    private(set) var isLoading: Bool = false {
        didSet { loadingView.display(viewModel: FeedLoadingViewModel(isLoading: isLoading)) }
    }
    
    var loadingView: FeedLoadingViewProtocol
    var fetchingView: FeedFetchingViewProtocol
    var errorView: FeedErrorViewProtocol
    
    init(loadingView: FeedLoadingViewProtocol, fetchingView: FeedFetchingViewProtocol, errorView: FeedErrorViewProtocol) {
        self.loadingView = loadingView
        self.fetchingView = fetchingView
        self.errorView = errorView
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
        errorView.display(FeedErrorViewModel(message: localizedString(for: "FEED_VIEW_CONNECTION_ERROR")))
    }
    
}
