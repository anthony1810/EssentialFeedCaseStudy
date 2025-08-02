//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 2/8/25.
//

import Foundation

public protocol ResourceView {
    func display(_ viewModel: String)
}

public final class LoadResourcePresenter {
    public typealias Mapper = (String) -> String
    private let loadingView: FeedLoadingView
    private let resourceView: ResourceView
    private let errorView: FeedErrorView
    private let mapper: Mapper
    
    public static var loadError: String {
        NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Load error for the feed view"
        )
    }
    
    public init(
        loadingView: FeedLoadingView,
        resourceView: ResourceView,
        errorView: FeedErrorView,
        mapper: @escaping Mapper
    ) {
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        self.errorView.display(.noError)
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with error: Error) {
        self.errorView.display(.error(message: FeedPresenter.loadError))
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: false))
    }
    
    public func display(resource: String) {
        self.resourceView.display(mapper(resource))
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: false))
        self.errorView.display(.noError)
    }
}
