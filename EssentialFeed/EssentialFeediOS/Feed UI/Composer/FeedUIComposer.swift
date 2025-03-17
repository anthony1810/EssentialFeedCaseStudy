import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        
        let feedLoaderPresenterAdapter = FeedLoaderPresenterAdapter(loader: feedLoader)
       
        let refreshController = FeedRefreshViewController(delegate: feedLoaderPresenterAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        let feedPresenter = FeedPresenter(
            loadingView: WeakRefVirtual(object: refreshController),
            feedView: FeedViewAdapter(controller: feedController, loader: imageLoader)
        )
        feedLoaderPresenterAdapter.presenter = feedPresenter
        
        return feedController
    }
    
    class FeedViewAdapter: FeedView {
        private weak var controller: FeedViewController?
        private let loader: FeedImageDataLoader
        
        init(controller: FeedViewController? = nil, loader: FeedImageDataLoader) {
            self.controller = controller
            self.loader = loader
        }
        
        func display(viewModel: FeedViewModel) {
            controller?.tableModel = viewModel.feeds.map { model in
                let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtual<FeedImageCellController>, UIImage>(model: model, imageLoader: loader)
                let view = FeedImageCellController(delegate: adapter)
                adapter.presenter = FeedImagePresenter(view: WeakRefVirtual(object: view), imageTransformer: UIImage.init)
                return view
            }
        }
    }
}

class WeakRefVirtual<T: AnyObject> {
    private weak var object: T?
    
    init(object: T ) {
        self.object = object
    }
}

extension WeakRefVirtual: LoadingView where T: LoadingView {
    func display(viewModel: LoadingViewModel) {
        object?.display(viewModel: viewModel)
    }
}

extension WeakRefVirtual: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(viewModel: FeedImageViewModel<UIImage>) {
        object?.display(viewModel: viewModel)
    }
}

class FeedLoaderPresenterAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.feedLoader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feeds):
                self?.presenter?.display(feeds: feeds)
            case .failure(let error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }
}

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case .success(let data):
                self?.presenter?.didFinishedLoadingImageData(with: data, for: model)
            case .failure(let error):
                self?.presenter?.didFinishedLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
