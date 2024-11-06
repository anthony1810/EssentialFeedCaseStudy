//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//
import Foundation

public final class FeedImagePresenter<Image, View: FeedImageView> where View.Image == Image {
    
    private var view: View
    private let imageTransformer: (Data) -> Any?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Any?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            url: model.imageURL,
            image: nil,
            isLoading: true,
            shouldRetry: false)
        )
    }
    
    public func didFinishLoadingImageData(for model: FeedImage, with error: Error) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            url: model.imageURL,
            image: nil,
            isLoading: false,
            shouldRetry: true)
        )
    }
    
    public func didFinishLoadingImageData(for model: FeedImage, with data: Data) {
        let image = imageTransformer(data)
        
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            url: model.imageURL,
            image: nil,
            isLoading: false,
            shouldRetry: image == nil)
        )
    }
}
