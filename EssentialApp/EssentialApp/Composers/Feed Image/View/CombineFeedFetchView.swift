//
//  CombineFeedFetchView.swift
//  EssentialApp
//
//  Created by Anthony on 1/12/24.
//
import Foundation
import UIKit
import EssentialFeed
import EssentialFeediOS

final class CombineFeedFetchView: FeedFetchingViewProtocol {
    private weak var feedViewController: FeedViewController?
    private var combineImageLoader: (URL) -> FeedImageDataLoaderProtocol.Publisher
    
    init(feedViewController: FeedViewController, combineImageLoader: @escaping (URL) -> FeedImageDataLoaderProtocol.Publisher) {
        self.feedViewController = feedViewController
        self.combineImageLoader = combineImageLoader
    }
    
    func display(viewModel: FeedFetchingViewModel) {
        feedViewController?.tableModels = viewModel.feeds.map {
            let presenterAdapter = CombineFeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(feed: $0, combineImageLoader: combineImageLoader)
           
            let view = FeedImageCellController(delegate: presenterAdapter)
            
            let presenter = FeedImagePresenter(view: WeakRefVirtualProxy(target: view), imageTransformer: UIImage.init)
            presenterAdapter.presenter = presenter
            
            return view
        }
    }
}

