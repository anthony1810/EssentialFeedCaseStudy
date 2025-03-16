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
    
    private static func adaptFeedCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
            }
        }
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
                FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
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
