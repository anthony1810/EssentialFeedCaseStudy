import EssentialFeed
import EssentialFeediOS
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        
        let feedLoaderPresenterAdapter = FeedLoaderPresenterAdapter(loader: MainQueueDecorator(decoratee: feedLoader))
        
        let feedController = makeFeedViewController(title: FeedPresenter.title, delegate: feedLoaderPresenterAdapter)
        
        let feedPresenter = FeedPresenter(
            loadingView: WeakRefVirtualProxy(object: feedController),
            feedView: FeedViewAdapter(controller: feedController, loader: MainQueueDecorator(decoratee: imageLoader)),
            errorView: WeakRefVirtualProxy(object: feedController)
        )
        feedLoaderPresenterAdapter.presenter = feedPresenter
        
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
