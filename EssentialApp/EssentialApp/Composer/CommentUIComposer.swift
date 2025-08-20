//
//  CommentUIComposer.swift
//  EssentialApp
//
//  Created by Anthony on 17/8/25.
//

import EssentialFeed
import EssentialFeediOS
import UIKit
import Combine

public final class CommentUIComposer {
    typealias FeedImagePresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    private init() {}
    
    public static func commentsComposedWith(
        commentLoaderPublisher: @escaping () -> AnyPublisher<[FeedImage], Error>
    ) -> ListViewController {
        
        let feedLoaderPresenterAdapter = FeedImagePresentationAdapter(loaderPublisher: {
            commentLoaderPublisher().dispatchOnMainQueueIfNeeded()
        })
        
        let feedController = makeFeedViewController(title: ImageCommentPresenter.title)
        feedController.didRequestFeedRefresh = feedLoaderPresenterAdapter.load
        
        let loadResourcePresenter = LoadResourcePresenter<[FeedImage], FeedViewAdapter>(
            loadingView: WeakRefVirtualProxy(object: feedController),
            resourceView: FeedViewAdapter(controller: feedController, loader: { _ in
                Empty<Data, Error>().eraseToAnyPublisher()
            }),
            errorView: WeakRefVirtualProxy(object: feedController),
            mapper: FeedPresenter.map
        )
        feedLoaderPresenterAdapter.presenter = loadResourcePresenter
        
        return feedController
    }
    
    private static func makeFeedViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}
