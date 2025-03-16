import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter()
        let feedLoaderPresenterAdapter = FeedLoaderPresenterAdapter(loader: feedLoader, presenter: feedPresenter)
        
        let refreshController = FeedRefreshViewController(delegate: feedLoaderPresenterAdapter)
        feedPresenter.loadingView = WeakRefVirtual(object: refreshController)
        let feedController = FeedViewController(refreshController: refreshController)
        
        feedPresenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
        
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
    private let presenter: FeedPresenter
    
    init(loader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = loader
        self.presenter = presenter
    }
    
    func didRequestFeedRefresh() {
        presenter.didStartLoading()
        
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feeds):
                self?.presenter.display(feeds: feeds)
            case .failure(let error):
                self?.presenter.didFinishLoading(with: error)
            }
        }
    }
}
