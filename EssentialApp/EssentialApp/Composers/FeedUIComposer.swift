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
        combineLoader: @escaping () -> FeedLoaderProtocol.Publisher,
        combineImageLoader: @escaping (URL) -> FeedImageDataLoaderProtocol.Publisher
    ) -> ListViewController {
        let feedLoaderPresentationAdapter = CombineResourceLoaderPresentationAdapter<[FeedImage], CombineFeedFetchView>(loader: combineLoader().dispatchToMainThread)
    
        let storyboard = UIStoryboard(name: "Feed", bundle: Bundle(for: ListViewController.self))
        let feedViewController = storyboard.instantiateInitialViewController() as! ListViewController
        
        feedViewController.delegate = feedLoaderPresentationAdapter
        feedViewController.title = localizedString(for: "FEED_VIEW_TITLE")
        
        let feedPresenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(target: feedViewController),
            errorView: WeakRefVirtualProxy(target: feedViewController),
            fetchingView: CombineFeedFetchView(
                feedViewController: feedViewController,
                combineImageLoader: { url in combineImageLoader(url).dispatchToMainThread() } ),
            mapper: FeedPresenter.map
        )
        feedLoaderPresentationAdapter.presenter = feedPresenter
        
        return feedViewController
    }
}



