//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 30/3/25.
//
import Foundation

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            viewModel: FeedImageViewModel(
                location: model.location,
                description: model.description,
                isLoading: true,
                shouldRetry: false)
        )
    }
    
    public func didFinishedLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(viewModel: FeedImageViewModel(
            location: model.location,
            description: model.description,
            isLoading: false,
            shouldRetry: true)
        )
    }
    
    private struct InvalidImageDataError: Error {}
    
    public func didFinishedLoadingImageData(with data: Data, for model: FeedImage) {
        guard let _ = imageTransformer(data) else {
            return didFinishedLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(viewModel: FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: imageTransformer(data),
            isLoading: false,
            shouldRetry: false)
        )
    }
    
    public static func map(_ feed: FeedImage) -> FeedImageViewModel<Image> {
        FeedImageViewModel(
            location: feed.location,
            description: feed.description,
            image: nil,
            isLoading: false,
            shouldRetry: false
        )
    }
}
