import Foundation
import EssentialFeed

struct LoadingViewModel {
    var isLoading: Bool
}
protocol LoadingView {
    func display(viewModel: LoadingViewModel)
}

protocol FeedView {
    func display(feeds: [FeedImage])
}

final class FeedPresenter {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var loadingView: LoadingView?
    var feedView: FeedView?
    
    func loadFeed() {
        loadingView?.display(viewModel: LoadingViewModel(isLoading: true))
        
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feeds: feed)
            }
            
            self?.loadingView?.display(viewModel: LoadingViewModel(isLoading: false))
        }
    }
}
