//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 16/3/25.
//
import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    var location: String?
    var description: String?
    var image: Image?
    var isLoading: Bool
    var shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}

protocol FeedImageView {
    associatedtype Image
    func display(viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {

    private let imageTransformer: (Data) -> Image?
    private let view: View
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            viewModel: FeedImageViewModel(
                location: model.location,
                description: model.description,
                isLoading: true,
                shouldRetry: false)
        )
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishedLoadingImageData(with data: Data, for model: FeedImage) {
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
    
    func didFinishedLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(viewModel: FeedImageViewModel(
            location: model.location,
            description: model.description,
            isLoading: false,
            shouldRetry: true)
        )
    }
}
