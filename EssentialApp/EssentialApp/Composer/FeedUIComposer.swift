import EssentialFeed
import EssentialFeediOS
import UIKit
import Combine

public final class FeedUIComposer {
    typealias FeedImagePresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    private init() {}
    
    public static func feedComposedWith(
        feedLoaderPublisher: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> ListViewController {
        
        let feedLoaderPresenterAdapter = FeedImagePresentationAdapter(loaderPublisher: {
            feedLoaderPublisher().dispatchOnMainQueueIfNeeded()
        })
        
        let feedController = makeFeedViewController(title: FeedPresenter.title)
        feedController.didRequestFeedRefresh = feedLoaderPresenterAdapter.load
        
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
    
    private static func makeFeedViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}
