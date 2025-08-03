import EssentialFeed
import EssentialFeediOS
import UIKit
import Combine

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(
        feedLoaderPublisher: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> FeedViewController {
        
        let feedLoaderPresenterAdapter = FeedLoaderPresenterAdapter(feedLoaderPublisher: {
            feedLoaderPublisher().dispatchOnMainQueueIfNeeded()
        })
        
        let feedController = makeFeedViewController(title: FeedPresenter.title, delegate: feedLoaderPresenterAdapter)
        
        let loadResourcePresenter = LoadResourcePresenter<[FeedImage], FeedViewAdapter>(
            loadingView: WeakRefVirtualProxy(object: feedController),
            resourceView: FeedViewAdapter(controller: feedController, loader: {
                imageLoader($0).dispatchOnMainQueueIfNeeded()
            }),
            errorView: WeakRefVirtualProxy(object: feedController),
            mapper: FeedPresenter.map
        )
        feedLoaderPresenterAdapter.presenter = loadResourcePresenter
        
        return feedController
    }
    
    private static func makeFeedViewController(title: String, delegate: FeedViewControllerDelegate) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
