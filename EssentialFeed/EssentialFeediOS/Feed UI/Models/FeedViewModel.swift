import Foundation
import EssentialFeed

protocol LoadingView: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feeds: [FeedImage])
}

final class FeedPresenter {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    weak var loadingView: LoadingView?
    var feedView: FeedView?
    
    func loadFeed() {
        loadingView?.display(isLoading: true)
        
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feeds: feed)
            }
            
            self?.loadingView?.display(isLoading: false)
        }
    }
}
