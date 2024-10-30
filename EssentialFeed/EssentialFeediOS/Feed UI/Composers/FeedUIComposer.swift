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
        
        let refreshViewModel = FeedRefreshViewModel(loader: loader)
        let refreshController = FeedRefreshController(viewModel: refreshViewModel, refreshController: refreshControl)
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        refreshViewModel.onLoadFeedCompletion = adaptFeedToCellControllers(forwardingTo: feedViewController, imageLoader: imageLoader)
        
        return feedViewController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo feedViewController: FeedViewController, imageLoader: FeedImageLoaderProtocol) -> (([FeedImage]) -> Void) {
        return { [weak feedViewController] feeds in
            feedViewController?.tableModels = feeds.map {
                FeedImageCellController(feed: $0, imageLoader: imageLoader)
            }
        }
    }
}
