//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Anthony on 17/3/25.
//
import EssentialFeed
import EssentialFeediOS
import UIKit
import Combine

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        cancellable = imageLoader(model.url)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.presenter?.didFinishedLoadingImageData(with: error, for: model)
                }
            }, receiveValue: { [weak self] data in
                self?.presenter?.didFinishedLoadingImageData(with: data, for: model)
            })
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
