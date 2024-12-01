//
//  CombineFeedLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Anthony on 1/12/24.
//
import Foundation
import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

final class CombineFeedLoaderPresentationAdapter: FeedRefreshDelegate {
    private let loader: () -> AnyPublisher<[FeedImage], Error>
    private var cancellable: Cancellable?
    var presenter: FeedPresenter?
    
    init(loader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.startLoading()
        cancellable = loader()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.presenter?.finishLoadingFailure(error: error)
                }
            }, receiveValue: { [weak self] feeds in
                self?.presenter?.finishLoadingSuccessfully(feeds: feeds)
            })
    }
}
