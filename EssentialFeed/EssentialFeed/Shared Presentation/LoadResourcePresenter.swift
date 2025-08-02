//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 2/8/25.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    private let loadingView: FeedLoadingView
    private let resourceView: View
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
        resourceView: View,
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
    
    public func display(resource: Resource) {
        self.resourceView.display(mapper(resource))
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: false))
        self.errorView.display(.noError)
    }
}
