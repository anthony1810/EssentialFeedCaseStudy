//
//  FeedFetchView.swift
//  EssentialFeed
//
//  Created by Anthony on 2/11/24.
//
import Foundation
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedFetchView: FeedFetchingViewProtocol {
    private weak var feedViewController: FeedViewController?
    private var imageLoader: FeedImageDataLoaderProtocol
    
    init(feedViewController: FeedViewController, imageLoader: FeedImageDataLoaderProtocol) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
    }
    
    func display(viewModel: FeedFetchingViewModel) {
        feedViewController?.tableModels = viewModel.feeds.map {
            let presenterAdapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(feed: $0, imageLoader: imageLoader)
           
            let view = FeedImageCellController(delegate: presenterAdapter)
            
            let presenter = FeedImagePresenter(view: WeakRefVirtualProxy(target: view), imageTransformer: UIImage.init)
            presenterAdapter.presenter = presenter
            
            return view
        }
    }
}
