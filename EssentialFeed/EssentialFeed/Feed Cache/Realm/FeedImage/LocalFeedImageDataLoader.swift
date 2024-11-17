//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 17/11/24.
//
import Foundation

public final class LocalFeedImageDataLoader: FeedImageLoaderProtocol {
    private let store: LocalFeedImageStoreProtocol
    
    public enum Error: Swift.Error, Equatable {
        case failed
        case notFound
    }
    
    private class Task: ImageLoadingDataTaskProtocol {
        private var completion: ((FeedImageLoaderProtocol.Result) -> Void)?
        
        init(completion: @escaping ((FeedImageLoaderProtocol.Result) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageLoaderProtocol.Result) {
            self.completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public init(store: LocalFeedImageStoreProtocol) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> any ImageLoadingDataTaskProtocol {
        let task = Task(completion: completion)
        
        store.retrieveData(for: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { data -> FeedImageLoaderProtocol.Result in
                    data.map { .success($0) } ?? .failure(Error.notFound)
                })
        })
        
        return task
    }
}
