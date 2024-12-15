//
//  CombineFeedImageDataLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Anthony on 1/12/24.
//

import Combine
import EssentialFeed
import Foundation
import EssentialFeediOS

final class CombineFeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
    private var imageLoader: (URL) -> FeedImageDataLoaderProtocol.Publisher
    private var feed: FeedImage
    private var cancellable: Cancellable?
    
    var presenter: FeedImagePresenter<Image, View>?
    
    init(feed: FeedImage, combineImageLoader: @escaping (URL) -> FeedImageDataLoaderProtocol.Publisher) {
        self.feed = feed
        self.imageLoader = combineImageLoader
    }
}

extension CombineFeedImageDataLoaderPresentationAdapter: FeedImageDataControllerDelegate {
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: feed)
        cancellable = imageLoader(feed.imageURL)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case let .failure(error) = completion {
                    self.presenter?.didFinishLoadingImageData(for: self.feed, with: error)
                }
            }, receiveValue: { [weak self] image in
                guard let self else { return }
                self.presenter?.didFinishLoadingImageData(for: self.feed, with: image)
            })
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
