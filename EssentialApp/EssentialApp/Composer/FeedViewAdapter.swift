//
//  FeedViewAdapter.swift
//  EssentialFeed
//
//  Created by Anthony on 17/3/25.
//
import EssentialFeed
import EssentialFeediOS
import UIKit

class FeedViewAdapter: ResourceView {
    typealias ResourceViewModel = FeedViewModel
    
    private weak var controller: FeedViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    
    init(
        controller: FeedViewController? = nil,
        loader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feeds.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: loader)
            
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(object: view), imageTransformer: UIImage.init)
            return view
        })
    }
}
