//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 1/11/24.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let location: String?
    let description: String?
    let url: URL
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}

protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<Image, View: FeedImageView> where View.Image == Image {
    
    private var view: View
    private struct InvalidImageDataError: Error {}

    private let imageTransformer: (Data) -> Image?
    
    init(imageTransformer: @escaping (Data) -> Image?, view: View) {
        self.imageTransformer = imageTransformer
        self.view = view
    }
}

extension FeedImagePresenter {
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            url: model.imageURL,
            image: nil,
            isLoading: true,
            shouldRetry: false)
        )
    }
    
    func didFinishLoadingImageData(for model: FeedImage, with data: Data) {
        guard let image = imageTransformer(data) else {
            didFinishLoadingImageData(for: model, with: InvalidImageDataError())
            return
        }
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            url: model.imageURL,
            image: image,
            isLoading: false,
            shouldRetry: false)
        )
    }
    
    func didFinishLoadingImageData(for model: FeedImage, with error: Error) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            url: model.imageURL,
            image: nil,
            isLoading: false,
            shouldRetry: true)
        )
    }
}
