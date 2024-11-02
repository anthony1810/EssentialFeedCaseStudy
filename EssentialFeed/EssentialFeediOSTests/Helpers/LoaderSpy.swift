//
//  LoaderSpy.swift
//  EssentialFeed
//
//  Created by Anthony on 28/10/24.
//
import Foundation
import EssentialFeed
import EssentialFeediOS
import UIKit

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
    private(set) var imageRequests = [(url: URL, completion: (FeedImageLoaderProtocol.Result) -> Void)]()
    var loadedImageURLs: [URL] { imageRequests.map(\.url) }
    private(set) var cancelLoadedImageURLs = [URL]()
    
    private struct LoadingImageTaskSpy: ImageLoadingDataTaskProtocol {
        let cancelCallBack: () -> Void
        func cancel() {
            cancelCallBack()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void ) -> ImageLoadingDataTaskProtocol {
        
        imageRequests.append((url, completion))
        
        return LoadingImageTaskSpy(cancelCallBack: { [weak self] in self?.cancelLoadedImageURLs.append(url) })
    }
    
    func completeImageLoadingSuccessfully(at index: Int, with imageData: Data = UIImage.make(withColor: .red).pngData()!) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithFailure(at index: Int, error: Error) {
        imageRequests[index].completion(.failure(error))
    }
}
