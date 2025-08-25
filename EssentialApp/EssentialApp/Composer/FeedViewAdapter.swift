//
//  FeedViewAdapter.swift
//  EssentialFeed
//
//  Created by Anthony on 17/3/25.
//
import EssentialFeed
import EssentialFeediOS
import UIKit

final class FeedViewAdapter: ResourceView {
    typealias ResourceViewModel = FeedViewModel
    typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    private weak var controller: ListViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    private let selectImageHandler: (FeedImage) -> Void
    
    init(
        controller: ListViewController? = nil,
        loader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selectImageHandler: @escaping (FeedImage) -> Void
    ) {
        self.controller = controller
        self.loader = loader
        self.selectImageHandler = selectImageHandler
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feeds.map { model in
            
            let adapter = ImageDataPresentationAdapter(loaderPublisher: { [loader] in
                loader(model.url)
            })
            
            let view = FeedImageCellController(
                delegate: adapter,
                viewModel: FeedImagePresenter.map(model),
                selectImageHandler: { [selectImageHandler] in
                    selectImageHandler(model)
                }
            )
            
            adapter.presenter = LoadResourcePresenter(
                loadingView: WeakRefVirtualProxy(object: view),
                resourceView: WeakRefVirtualProxy(object: view),
                errorView: WeakRefVirtualProxy(object: view),
                mapper: UIImage.tryMake
            )
            
            return CellController(id: model.id, ds: view, dl: view, dsPrefetching: view)
        })
    }
}

struct InvalidImageError: Error {}
extension UIImage {
    static func tryMake(from data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageError()
        }
        return image
    }
}
