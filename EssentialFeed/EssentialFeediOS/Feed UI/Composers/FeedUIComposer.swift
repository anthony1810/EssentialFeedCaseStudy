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
        let refreshViewController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedVC = FeedViewController(
            feedLoader: feedLoader,
            imageDataLoader: imageDataLoader,
            refreshViewController: refreshViewController
        )
        
        refreshViewController.onRefresh = { [weak feedVC] feeds in
            feedVC?.tableModels = feeds
                .map { FeedImageCellController(imageDataLoader: imageDataLoader, feed: $0) }
        }
        
        return feedVC
    }
}
