//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//

import Foundation
import UIKit
import EssentialFeed

public enum FeedUIComposer {
    public static func composeFeedViewController(
        loader: FeedLoader,
        imageLoader: FeedImageLoaderProtocol,
        refreshControl: UIRefreshControl = .init()
    ) -> FeedViewController {
        
        let feedPresenter = FeedPresenter(loader: loader)
        let refreshController = FeedRefreshController(presenter: feedPresenter, refreshController: refreshControl)
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        let fetchingView = FeedFetchView(feedViewController: feedViewController, imageLoader: imageLoader)
        feedPresenter.loadingView = WeakRefVirtualProxy(target: refreshController)
        feedPresenter.fetchingView = fetchingView
        
        return feedViewController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo feedViewController: FeedViewController, imageLoader: FeedImageLoaderProtocol) -> (([FeedImage]) -> Void) {
        return { [weak feedViewController] feeds in
            feedViewController?.tableModels = feeds.map {
                let viewModel = FeedImageCellViewModel(feed: $0, imageLoader: imageLoader, imageTransformer: UIImage.init)
                return FeedImageCellController(viewModel: viewModel)
            }
        }
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var target: T?
    
    init(target: T) {
        self.target = target
    }
}

extension WeakRefVirtualProxy: FeedLoadingViewProtocol where T: FeedLoadingViewProtocol {
    func display(viewModel: FeedLoadingViewModel) {
        target?.display(viewModel: viewModel)
    }
}

final class FeedFetchView: FeedFetchingViewProtocol {
    private weak var feedViewController: FeedViewController?
    private var imageLoader: FeedImageLoaderProtocol
    
    init(feedViewController: FeedViewController, imageLoader: FeedImageLoaderProtocol) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
    }
    
    func display(feeds: [EssentialFeed.FeedImage]) {
        feedViewController?.tableModels = feeds.map {
            let viewModel = FeedImageCellViewModel(feed: $0, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}
