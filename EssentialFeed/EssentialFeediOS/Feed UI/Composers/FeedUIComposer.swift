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
        imageLoader: FeedImageLoaderProtocol
    ) -> FeedViewController {
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(loader: loader)
    
        let storyboard = UIStoryboard(name: "Feed", bundle: Bundle(for: FeedViewController.self))
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        
        let refreshController = feedViewController.refreshController!
        refreshController.delegate = feedLoaderPresentationAdapter
        
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



