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
    private let loadingView: LoadingView
    private let feedView: FeedView
    
    init(loadingView: LoadingView, feedView: FeedView) {
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    func didStartLoading() {
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: true))
    }
    
    func didFinishLoading(with error: Error) {
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: false))
    }
    
    func display(feeds: [FeedImage]) {
        self.feedView.display(viewModel: FeedViewModel(feeds: feeds))
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: false))
    }
}
