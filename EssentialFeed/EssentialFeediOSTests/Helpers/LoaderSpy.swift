//
//  LoaderSpy.swift
//  EssentialFeed
//
//  Created by Anthony on 28/10/24.
//
import Foundation
import EssentialFeed
import EssentialFeediOS

final class LoaderSpy: FeedLoader, FeedImageLoaderProtocol {

    private(set) var feedRequests = [(FeedLoader.Result) -> Void]()
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedRequests.append(completion)
    }
    
    func completeFeedLoadingSuccess(at index: Int = 0, with images: [FeedImage] = []) {
        feedRequests[index](.success(images))
    }
    
    func completeFeedLoadingWithFailure(at index: Int, error: Error) {
        feedRequests[index](.failure(error))
    }
    
    // MARK: - Image Loader
    private(set) var loadedImageURLs = [URL]()
    private(set) var cancelLoadedImageURLs = [URL]()
    
    private struct LoadingImageTaskSpy: ImageLoadingDataTaskProtocol {
        let cancelCallBack: () -> Void
        func cancel() {
            cancelCallBack()
        }
    }
    
    func loadImageData(from url: URL) -> ImageLoadingDataTaskProtocol {
        loadedImageURLs.append(url)
        return LoadingImageTaskSpy(cancelCallBack: { [weak self] in self?.cancelLoadedImageURLs.append(url) })
    }
}
