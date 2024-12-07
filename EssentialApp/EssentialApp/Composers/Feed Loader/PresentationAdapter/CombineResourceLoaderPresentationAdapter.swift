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

final class CombineResourceLoaderPresentationAdapter<Resource, View: ResourceFetchingViewProtocol> {
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<Resource, View>?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.startLoading()
        cancellable = loader()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.presenter?.finishLoadingFailure(error: error)
                }
            }, receiveValue: { [weak self] feeds in
                self?.presenter?.finishLoadingSuccessfully(with: feeds)
            })
    }
}

extension CombineResourceLoaderPresentationAdapter: FeedRefreshDelegate {
    func didRequestFeedRefresh() {
        self.loadResource()
    }
}
