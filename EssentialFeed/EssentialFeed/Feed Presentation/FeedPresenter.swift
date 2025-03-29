//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//
import Foundation

public struct LoadingViewModel {
    public var isLoading: Bool
}
public protocol FeedLoadingView {
    func display(viewModel: LoadingViewModel)
}

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: Self {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public struct FeedViewModel {
    public var feeds: [FeedImage]
}
public protocol FeedView {
    func display(viewModel: FeedViewModel)
}

public final class FeedPresenter {
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView
    
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
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Load error for the feed view"
        )
    }
    
    public init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    public func didStartLoading() {
        self.errorView.display(.noError)
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with error: Error) {
        self.errorView.display(.error(message: FeedPresenter.loadError))
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: false))
    }
    
    public func display(feeds: [FeedImage]) {
        self.feedView.display(viewModel: FeedViewModel(feeds: feeds))
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: false))
        self.errorView.display(.noError)
    }
}
