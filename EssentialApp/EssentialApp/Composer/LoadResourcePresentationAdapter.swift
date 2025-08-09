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

class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private let loaderPublisher: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<Resource, View>?
    
    init(loaderPublisher: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loaderPublisher = loaderPublisher
    }
    
    func load() {
        presenter?.didStartLoading()
        cancellable = loaderPublisher().sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.presenter?.didFinishLoading(with: error)
                }
            }, receiveValue: { [weak self] resource in
                self?.presenter?.display(resource: resource)
            })
    }
}

extension LoadResourcePresentationAdapter: FeedViewControllerDelegate {
    func didRequestFeedRefresh() {
        self.load()
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        self.load()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
