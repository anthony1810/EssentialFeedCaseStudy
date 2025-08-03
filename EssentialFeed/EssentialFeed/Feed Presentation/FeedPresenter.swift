//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//
import Foundation

public final class FeedPresenter {
    private let loadingView: ResourceLoadingView
    private let feedView: FeedView
    private let errorView: ResourceErrorView
    
    public static var title: String {
        NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }
    
    public static var loadError: String {
        NSLocalizedString(
            "GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Load error for the feed view"
        )
    }
    
    public init(loadingView: ResourceLoadingView, feedView: FeedView, errorView: ResourceErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    public func didStartLoading() {
        self.errorView.display(.noError)
        self.loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with error: Error) {
        self.errorView.display(.error(message: FeedPresenter.loadError))
        self.loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
    }
    
    public func display(feeds: [FeedImage]) {
        self.feedView.display(viewModel: FeedViewModel(feeds: feeds))
        self.loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
        self.errorView.display(.noError)
    }
}
