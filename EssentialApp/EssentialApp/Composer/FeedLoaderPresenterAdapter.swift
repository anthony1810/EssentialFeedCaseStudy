//
//  FeedLoaderPresenterAdapter.swift
//  EssentialFeed
//
//  Created by Anthony on 17/3/25.
//
import EssentialFeed
import EssentialFeediOS
import UIKit
import Combine

class FeedLoaderPresenterAdapter: FeedViewControllerDelegate {
    private let feedLoaderPublisher: () -> AnyPublisher<[FeedImage], Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    
    init(feedLoaderPublisher: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoaderPublisher = feedLoaderPublisher
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        cancellable = feedLoaderPublisher().sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.presenter?.didFinishLoading(with: error)
                }
            }, receiveValue: { [weak self] feed in
                self?.presenter?.display(resource: feed)
            })
    }
}
