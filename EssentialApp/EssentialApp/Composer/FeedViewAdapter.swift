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
    typealias ResourceViewModel = Paginated<FeedImage>
    
    typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
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
    
    func display(_ viewModel: Paginated<FeedImage>) {
        let feed: [CellController] = viewModel.items.map { model in
            
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
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller?.display(feed)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loaderPublisher: loadMorePublisher)
        let loadMoreCellController = LoadMoreCellController(willDisplayCallback: {
            loadMoreAdapter.load()
        })
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(object: loadMoreCellController),
            resourceView: self,
            errorView: WeakRefVirtualProxy(object: loadMoreCellController)
        )
        
        let loadMoreSection = [CellController(id: UUID(), ds: loadMoreCellController, dl: loadMoreCellController, dsPrefetching: nil)]
        
        controller?.display(feed, loadMoreSection)
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
