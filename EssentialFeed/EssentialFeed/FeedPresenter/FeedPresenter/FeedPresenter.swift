//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//

import Foundation

public class FeedPresenter {
    private var loadingView: FeedLoadingViewProtocol
    private var errorView: FeedErrorViewProtocol
    private var fetchingView: FeedFetchingViewProtocol
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self),  comment: "Error Message displayed when there is an error loading the feed")
    }
    
    public var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self),  comment: "Error Message displayed when there is an error loading the feed")
    }
    
    public init(
        loadingView: FeedLoadingViewProtocol,
        errorView: FeedErrorViewProtocol,
        fetchingView: FeedFetchingViewProtocol
    ) {
        self.loadingView = loadingView
        self.errorView = errorView
        self.fetchingView = fetchingView
    }
    
    public func startLoading() {
        loadingView.display(.isLoading)
        errorView.display(.noError)
    }
    
    public func finishLoadingSuccessfully(feeds: [FeedImage]) {
        fetchingView.display(viewModel: FeedFetchingViewModel(feeds: feeds))
        loadingView.display(.noLoading)
    }
    
    public func finishLoadingFailure(error: Error) {
        loadingView.display(.noLoading)
        errorView.display(.error(message: localizedString(for: "FEED_VIEW_CONNECTION_ERROR")))
    }
}
