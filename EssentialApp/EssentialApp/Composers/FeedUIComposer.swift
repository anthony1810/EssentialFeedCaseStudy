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
import Combine

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
    
    public static func composeFeedViewController(
        combineLoader: @escaping () -> FeedLoaderProtocol.Publisher,
        combineImageLoader: @escaping (URL) -> FeedImageDataLoaderProtocol.Publisher
    ) -> FeedViewController {
        let feedLoaderPresentationAdapter = CombineFeedLoaderPresentationAdapter(loader: combineLoader().dispatchToMainThread)
    
        let storyboard = UIStoryboard(name: "Feed", bundle: Bundle(for: FeedViewController.self))
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        
        feedViewController.delegate = feedLoaderPresentationAdapter
        feedViewController.title = localizedString(for: "FEED_VIEW_TITLE")
        
        let feedPresenter = FeedPresenter(
            loadingView: WeakRefVirtualProxy(target: feedViewController),
            errorView: WeakRefVirtualProxy(target: feedViewController),
            fetchingView: CombineFeedFetchView(
                feedViewController: feedViewController,
                combineImageLoader: { url in combineImageLoader(url).dispatchToMainThread() } )
           
        )
        feedLoaderPresentationAdapter.presenter = feedPresenter
        
        return feedViewController
    }
}



