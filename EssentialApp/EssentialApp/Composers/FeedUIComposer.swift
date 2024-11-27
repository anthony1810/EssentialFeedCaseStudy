//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//

import Foundation
import UIKit
import EssentialFeed
import EssentialFeediOS

public enum FeedUIComposer {
    public static func composeFeedViewController(
        loader: FeedLoaderProtocol,
        imageLoader: FeedImageDataLoaderProtocol
    ) -> FeedViewController {
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(loader: MainThreadDecorator(loader))
    
        let storyboard = UIStoryboard(name: "Feed", bundle: Bundle(for: FeedViewController.self))
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        
        feedViewController.delegate = feedLoaderPresentationAdapter
        feedViewController.title = localizedString(for: "FEED_VIEW_TITLE")
        
        let feedPresenter = FeedPresenter(
            loadingView: WeakRefVirtualProxy(target: feedViewController),
            errorView: WeakRefVirtualProxy(target: feedViewController),
            fetchingView: FeedFetchView(
                feedViewController: feedViewController,
                imageLoader: MainThreadDecorator(imageLoader))
           
        )
        feedLoaderPresentationAdapter.presenter = feedPresenter
        
        return feedViewController
    }
}



