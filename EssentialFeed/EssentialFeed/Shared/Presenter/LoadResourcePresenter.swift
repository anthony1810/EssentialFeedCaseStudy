//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 7/12/24.
//

import Foundation

public protocol ResourceFetchingViewProtocol {
    func display(viewModel: String)
}

public class LoadResourcePresenter {
    public typealias Mapper = (String) -> String
    
    private var loadingView: FeedLoadingViewProtocol
    private var errorView: FeedErrorViewProtocol
    private var fetchingView: ResourceFetchingViewProtocol
    
    private var mapper: Mapper
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self),  comment: "Error Message displayed when there is an error loading the feed")
    }
    
    public init(
        loadingView: FeedLoadingViewProtocol,
        errorView: FeedErrorViewProtocol,
        fetchingView: ResourceFetchingViewProtocol,
        mapper: @escaping Mapper
    ) {
        self.loadingView = loadingView
        self.errorView = errorView
        self.fetchingView = fetchingView
        self.mapper = mapper
    }
    
    public func startLoading() {
        loadingView.display(.isLoading)
        errorView.display(.noError)
    }
    
    public func finishLoadingSuccessfully(with resource: String) {
        fetchingView.display(viewModel: mapper(resource))
        loadingView.display(.noLoading)
    }
    
    public func finishLoadingFailure(error: Error) {
        loadingView.display(.noLoading)
        errorView.display(.error(message: localizedString(for: "FEED_VIEW_CONNECTION_ERROR")))
    }
}
