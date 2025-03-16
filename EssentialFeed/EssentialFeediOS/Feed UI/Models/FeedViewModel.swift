import Foundation
import EssentialFeed

struct LoadingViewModel {
    var isLoading: Bool
}
protocol LoadingView {
    func display(viewModel: LoadingViewModel)
}

struct FeedViewModel {
    var feeds: [FeedImage]
}
protocol FeedView {
    func display(viewModel: FeedViewModel)
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
                self?.feedView?.display(viewModel: FeedViewModel(feeds: feed))
            }
            
            self?.loadingView?.display(viewModel: LoadingViewModel(isLoading: false))
        }
    }
}
