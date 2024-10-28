//
//  LoaderSpy.swift
//  EssentialFeed
//
//  Created by Anthony on 28/10/24.
//
import Foundation
import EssentialFeed
import EssentialFeediOS

class LoaderSpy: FeedLoader, FeedImageLoaderProtocol {
    
    var loadCompletionResult = [(FeedLoader.Result) -> Void]()
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        loadCompletionResult.append(completion)
    }
    
    func completeFeedLoadingSuccess(at index: Int = 0, with images: [FeedImage] = []) {
        loadCompletionResult[index](.success(images))
    }
    
    func completeFeedLoadingWithFailure(at index: Int, error: Error) {
        loadCompletionResult[index](.failure(error))
    }
    
    // MARK: - Image Loader
    var loadedImageURLs = [URL]()
    func loadImageData(from url: URL) {
        loadedImageURLs.append(url)
    }
}
