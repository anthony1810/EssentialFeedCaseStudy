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
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(loader: loader)
        let refreshController = FeedRefreshController(delegate: feedLoaderPresentationAdapter, refreshController: refreshControl)
        
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        let feedPresenter = FeedPresenter(
            loadingView: WeakRefVirtualProxy(target: refreshController),
            fetchingView: FeedFetchView(
                feedViewController: feedViewController,
                imageLoader: imageLoader)
        )
        feedLoaderPresentationAdapter.presenter = feedPresenter
        
        return feedViewController
    }
}

final class FeedLoaderPresentationAdapter: FeedRefreshControllerDelegate {
    private let loader: FeedLoader
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.startLoading()
        loader.load { [weak self] result in
            switch result {
            case .success(let feeds):
                self?.presenter?.finishLoadingSuccessfully(feeds: feeds)
            case .failure(let error):
                self?.presenter?.finishLoadingFailure(error: error)
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
            let presenterAdapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(feed: $0, imageLoader: imageLoader)
           
            let view = FeedImageCellController(delegate: presenterAdapter)
            
            let presenter = FeedImagePresenter(imageTransformer: UIImage.init, view: WeakRefVirtualProxy(target: view))
            presenterAdapter.presenter = presenter
            
            return view
        }
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        target?.display(model)
    }
}
