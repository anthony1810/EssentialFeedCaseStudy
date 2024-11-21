//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Anthony on 1/11/24.
//
import Foundation
import EssentialFeed

protocol FeedImageDataControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
    private var imageLoader: FeedImageLoaderProtocol
    private var loadingImageTask: ImageLoadingDataTaskProtocol?
    private var feed: FeedImage
    
    var presenter: FeedImagePresenter<Image, View>?
    
    init(feed: FeedImage, imageLoader: FeedImageLoaderProtocol) {
        self.feed = feed
        self.imageLoader = imageLoader
    }
}

extension FeedImageDataLoaderPresentationAdapter: FeedImageDataControllerDelegate {
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: feed)
        self.loadingImageTask = self.imageLoader.loadImageData(from: feed.imageURL, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let image?):
                self.presenter?.didFinishLoadingImageData(for: self.feed, with: image)
            case .failure(let error):
                self.presenter?.didFinishLoadingImageData(for: self.feed, with: error)
            default: break
            }
        })
    }
    
    func didCancelImageRequest() {
        self.loadingImageTask?.cancel()
        self.loadingImageTask = nil
    }
}
