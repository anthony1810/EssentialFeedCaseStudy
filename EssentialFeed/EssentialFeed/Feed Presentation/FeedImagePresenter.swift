//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 30/3/25.
//
import Foundation

public struct FeedImageViewModel<Image> {
    public var location: String?
    public var description: String?
    public var image: Image?
    public var isLoading: Bool
    public var shouldRetry: Bool

    public var hasLocation: Bool {
        location != nil
    }
}

public protocol FeedImageView {
    associatedtype Image
    func display(viewModel: FeedImageViewModel<Image>)
}

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
}
