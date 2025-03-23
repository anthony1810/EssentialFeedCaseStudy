import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        
        let feedLoaderPresenterAdapter = FeedLoaderPresenterAdapter(loader: feedLoader)
        
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
       
        feedController.delegate = feedLoaderPresenterAdapter
        
        let feedPresenter = FeedPresenter(
            loadingView: WeakRefVirtualProxy(object: feedController),
            feedView: FeedViewAdapter(controller: feedController, loader: imageLoader)
        )
        feedLoaderPresenterAdapter.presenter = feedPresenter
        
        return feedController
    }
}



