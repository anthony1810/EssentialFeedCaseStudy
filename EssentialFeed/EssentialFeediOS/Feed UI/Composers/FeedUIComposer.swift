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



