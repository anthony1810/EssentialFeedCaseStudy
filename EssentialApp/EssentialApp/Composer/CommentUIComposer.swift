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
    typealias ImageCommentPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
    private init() {}
    
    public static func commentsComposedWith(
        commentLoaderPublisher: @escaping () -> AnyPublisher<[ImageComment], Error>
    ) -> ListViewController {
        
        let commentLoaderPresenterAdapter = ImageCommentPresentationAdapter(loaderPublisher: {
            commentLoaderPublisher().dispatchOnMainQueueIfNeeded()
        })
        
        let commentController = makeCommentViewController(title: ImageCommentPresenter.title)
        commentController.didRequestRefresh = commentLoaderPresenterAdapter.load
        
        let loadResourcePresenter = LoadResourcePresenter<[ImageComment], CommentsViewAdapter>(
            loadingView: WeakRefVirtualProxy(object: commentController),
            resourceView: CommentsViewAdapter(controller: commentController),
            errorView: WeakRefVirtualProxy(object: commentController),
            mapper: { comments in
                ImageCommentPresenter.map(comments)
            }
        )
        commentLoaderPresenterAdapter.presenter = loadResourcePresenter
        
        return commentController
    }
    
    private static func makeCommentViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComment", bundle: bundle)
        let commentController = storyboard.instantiateInitialViewController() as! ListViewController
        commentController.title = title
        return commentController
    }
}
