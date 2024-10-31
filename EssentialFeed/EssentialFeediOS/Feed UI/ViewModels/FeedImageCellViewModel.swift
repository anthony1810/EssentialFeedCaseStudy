//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//
import Foundation
import EssentialFeed
import UIKit

final class FeedImageCellViewModel {
    
    typealias Observer<T> = (T) -> Void
    
    private var imageLoader: FeedImageLoaderProtocol
    private var loadingImageTask: ImageLoadingDataTaskProtocol?
    private var feed: FeedImage
    
    var onImageLoaded: Observer<UIImage?>?
    var onLoadingStateChanged: Observer<Bool>?
    var shouldShowRetryStateChange: Observer<Bool>?
    
    init(feed: FeedImage, imageLoader: FeedImageLoaderProtocol) {
        self.feed = feed
        self.imageLoader = imageLoader
    }
}

extension FeedImageCellViewModel {
    func startImageDownloadTask() {
        
        self.onLoadingStateChanged?(true)
        self.shouldShowRetryStateChange?(false)
        
        self.loadingImageTask = self.imageLoader.loadImageData(from: imageURL, completion: { [weak self] result in
            self?.handleResult(result)
        })
    }
    
    func prefetchImage() {
        self.loadingImageTask = self.imageLoader.loadImageData(from: imageURL) { _ in }
    }
    
    func cancelLoadingImageTask() {
        self.loadingImageTask?.cancel()
        self.loadingImageTask = nil
    }
}

// MARK: - Helpers
extension FeedImageCellViewModel {
    func handleResult(_ result: Result<Data, Error>) {
        let image = (try? result.get()).flatMap(UIImage.init)
        self.onImageLoaded?(image)
        self.onLoadingStateChanged?(false)
        self.shouldShowRetryStateChange?(image == nil)
    }
}

// MARK: - Getter
extension FeedImageCellViewModel {
    var imageURL: URL {
        feed.imageURL
    }
    
    var location: String? {
        feed.location
    }
    
    var description: String? {
        feed.description
    }
}
