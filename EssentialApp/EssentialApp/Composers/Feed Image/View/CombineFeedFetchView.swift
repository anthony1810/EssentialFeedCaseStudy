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

final class CombineFeedFetchView: ResourceFetchingViewProtocol {
    private weak var feedViewController: ListViewController?
    private var combineImageLoader: (URL) -> FeedImageDataLoaderProtocol.Publisher
    
    init(feedViewController: ListViewController, combineImageLoader: @escaping (URL) -> FeedImageDataLoaderProtocol.Publisher) {
        self.feedViewController = feedViewController
        self.combineImageLoader = combineImageLoader
    }
    
    
    func display(viewModel: FeedFetchingViewModel) {
        feedViewController?.tableModels = viewModel.feeds.map { model in
            
            let presenterAdapter = CombineResourceLoaderPresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [combineImageLoader] in combineImageLoader(model.imageURL)})
        
           
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: presenterAdapter
            )
            
            let presenter = LoadResourcePresenter<Data, WeakRefVirtualProxy<FeedImageCellController>>(
                loadingView: WeakRefVirtualProxy(target: view),
                errorView: WeakRefVirtualProxy(target: view),
                fetchingView: WeakRefVirtualProxy(target: view),
                mapper: UIImage.tryMake)
            presenterAdapter.presenter = presenter
            
            return view
        }
    }
}

extension UIImage {
    
    struct FailedImageMapperError: Error {}
    
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw FailedImageMapperError()
        }
        return image
    }
}

