import Foundation
import EssentialFeed

struct LoadingViewModel {
    var isLoading: Bool
}
protocol FeedLoadingView {
    func display(viewModel: LoadingViewModel)
}

struct FeedViewModel {
    var feeds: [FeedImage]
}
protocol FeedView {
    func display(viewModel: FeedViewModel)
}

struct FeedErrorViewModel {
    let message: String?
    
    static var none: Self {
        .init(message: nil)
    }
}
protocol FeedErrorView {
    func display(viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView
    
    init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    static var title: String {
        NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }
    
    static var loadError: String {
        NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Load error for the feed view"
        )
    }
    
    func didStartLoading() {
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: true))
    }
    
    func didFinishLoading(with error: Error) {
        self.errorView.display(viewModel: FeedErrorViewModel(message: FeedPresenter.loadError))
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: false))
    }
    
    func display(feeds: [FeedImage]) {
        self.feedView.display(viewModel: FeedViewModel(feeds: feeds))
        self.loadingView.display(viewModel: LoadingViewModel(isLoading: false))
        self.errorView.display(viewModel: .none)
    }
}
