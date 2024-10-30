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
    public static func composeFeedViewController(loader: FeedLoader, imageLoader: FeedImageLoaderProtocol) -> FeedViewController {
        
        let refreshController = FeedRefreshController(loader: loader)
        let feedViewControllers = FeedViewController(refreshController: refreshController)
        
        refreshController.onRefreshComplete = { [weak feedViewControllers] feeds in
            guard let feedViewControllers else { return }
            feedViewControllers.tableModels = feeds.map {
                FeedImageCellController(feed: $0, imageLoader: imageLoader)
            }
        }
        
        return feedViewControllers
    }
}
