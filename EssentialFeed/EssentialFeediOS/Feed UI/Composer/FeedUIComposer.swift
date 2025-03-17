import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        
        let feedLoaderPresenterAdapter = FeedLoaderPresenterAdapter(loader: feedLoader)
       
        let refreshController = FeedRefreshViewController(delegate: feedLoaderPresenterAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        let feedPresenter = FeedPresenter(
            loadingView: WeakRefVirtualProxy(object: refreshController),
            feedView: FeedViewAdapter(controller: feedController, loader: imageLoader)
        )
        feedLoaderPresenterAdapter.presenter = feedPresenter
        
        return feedController
    }
}



