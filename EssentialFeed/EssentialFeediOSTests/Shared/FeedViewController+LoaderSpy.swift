//
//  FeedViewController+LoaderSpy.swift
//  EssentialFeed
//
//  Created by Anthony on 24/2/25.
//
import EssentialFeed
import EssentialFeediOS
import Foundation

extension EssentialFeediOSTests {
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - Feed Loader
        var loadFeedCalls: Int {
            feedFetchingCompletions.count
        }
        
        var feedFetchingCompletions: [(FeedLoader.Result) -> Void] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedFetchingCompletions.append(completion)
        }
        
        func completeLoadingFeed(_ feeds: [FeedImage] = [], at index: Int = 0) {
            feedFetchingCompletions[index](.success(feeds))
        }
        
        func completeLoadingFeedWithError(_ error: Error = anyNSError(), at index: Int = 0) {
            feedFetchingCompletions[index](.failure(error))
        }
        
        // MARK: - Image Data Loader
        var imageRequest = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedImageURLs: [URL] {
            imageRequest.map(\.url)
        }
        var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
            imageRequest.append((url, completion))
            
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(at index: Int, data: Data = Data()) {
            imageRequest[index].completion(.success(data))
        }
        
        func completeImageLoadingWithError(_ error: Error = anyNSError(), at index: Int) {
            imageRequest[index].completion(.failure(error))
        }
    }
}
