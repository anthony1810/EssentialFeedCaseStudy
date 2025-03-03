//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by Anthony on 25/2/25.
//
import UIKit

import EssentialFeed

public enum FeedUIComposer {
    public static func makeFeedViewController(
        feedLoader: FeedLoader,
        imageDataLoader: FeedImageDataLoader
    ) -> FeedViewController {
        let feedRefreshViewModel = FeedRefreshViewModel(feedLoader: feedLoader)
        let refreshViewController = FeedRefreshViewController(viewModel: feedRefreshViewModel)
        let feedVC = FeedViewController(
            feedLoader: feedLoader,
            imageDataLoader: imageDataLoader,
            refreshViewController: refreshViewController
        )
        
        feedRefreshViewModel.onRefresh = adapterFeedsToCellControllers(forwarding: feedVC, imageDataLoader: imageDataLoader)
        
        return feedVC
    }
    
    static func adapterFeedsToCellControllers(forwarding feedVC: FeedViewController, imageDataLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak feedVC] feeds in
            feedVC?.tableModels = feeds
                .map { FeedImageCellController(imageDataLoader: imageDataLoader, feed: $0) }
        }
    }
}
