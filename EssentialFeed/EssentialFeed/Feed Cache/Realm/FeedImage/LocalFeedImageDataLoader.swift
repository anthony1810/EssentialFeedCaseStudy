//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 17/11/24.
//
import Foundation

public final class LocalFeedImageDataLoader {
    
    private class Task: ImageLoadingDataTaskProtocol {
        private var completion: ((FeedImageDataLoaderProtocol.Result) -> Void)?
        
        init(completion: @escaping ((FeedImageDataLoaderProtocol.Result) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoaderProtocol.Result) {
            self.completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    private let store: LocalFeedImageStoreProtocol
    
    public init(store: LocalFeedImageStoreProtocol) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoaderProtocol {

    public enum LoadError: Swift.Error, Equatable {
        case failed
        case notFound
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoaderProtocol.Result) -> Void) -> any ImageLoadingDataTaskProtocol {
        let task = Task(completion: completion)
        
        store.retrieveData(for: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data -> FeedImageDataLoaderProtocol.Result in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                })
        })
        
        return task
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCacheProtocol {
    public typealias SaveResult = FeedImageDataCacheProtocol.SaveResult
    
    public enum SaveError: Swift.Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            
            completion(
                result
                    .mapError { _ in SaveError.failed }
                    .flatMap { _ in .success(data)}
                
            )
        }
    }
}
