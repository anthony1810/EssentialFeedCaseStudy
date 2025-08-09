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
            
            let adapter = LoadResourcePresentationAdapter<Data, FeedImageCellController>(loaderPublisher: { [loader] in
                loader(model.url)
            })
            
            let view = FeedImageCellController(
                delegate: adapter,
                viewModel: FeedImagePresenter<FeedImageCellController, UIImage>.map(model)
            )
            
            adapter.presenter = LoadResourcePresenter(
                loadingView: WeakRefVirtualProxy(object: view),
                resourceView: WeakRefVirtualProxy(object: view),
                errorView: WeakRefVirtualProxy(object: view),
                mapper: { data in
                    do {
                        guard let image = try UIImage(data: data) else {
                            throw InvalidImageError()
                        }
                        return image
                    } catch {
                        throw error
                    }
                }
            )
            
            return view
        })
    }
}

struct InvalidImageError: Error {}
