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
        
        let feedPresenter = FeedPresenter()
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(loader: loader, presenter: feedPresenter)
        let refreshController = FeedRefreshController(delegate: feedLoaderPresentationAdapter, refreshController: refreshControl)
        
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        let fetchingView = FeedFetchView(feedViewController: feedViewController, imageLoader: imageLoader)
        feedPresenter.loadingView = WeakRefVirtualProxy(target: refreshController)
        feedPresenter.fetchingView = fetchingView
        
        return feedViewController
    }
}

final class FeedLoaderPresentationAdapter: FeedRefreshControllerDelegate {
    private let loader: FeedLoader
    private let presenter: FeedPresenter
    
    init(loader: FeedLoader, presenter: FeedPresenter) {
        self.loader = loader
        self.presenter = presenter
    }
    
    func didRequestFeedRefresh() {
        presenter.startLoading()
        loader.load { [weak self] result in
            switch result {
            case .success(let feeds):
                self?.presenter.finishLoadingSuccessfully(feeds: feeds)
            case .failure(let error):
                self?.presenter.finishLoadingFailure(error: error)
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
    
    func display(viewModel: FeedFetchingViewModel) {
        feedViewController?.tableModels = viewModel.feeds.map {
            let viewModel = FeedImageCellViewModel(feed: $0, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}
