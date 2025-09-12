//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 13/4/25.
//

import Foundation

public final class LocalFeedImageDataLoader {
    let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

// MARK: - FeedImageDataLoader
extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    class LoadImageDataTask: FeedImageDataLoaderTask {
        var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping ((FeedImageDataLoader.Result) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFutherCompletions()
        }
        
        private func preventFutherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = LoadImageDataTask(completion: completion)
        task.complete(
            with: Swift.Result{
                try store.retrieve(dataForURL: url)
            }
            .mapError { _ in LocalFeedImageDataLoader.LoadError.failed }
            .flatMap { data in
                data.map { .success($0) } ?? .failure(LocalFeedImageDataLoader.LoadError.notFound)
            })
        
        return task
    }
}

// MARK: - SaveResult
extension LocalFeedImageDataLoader: FeedImageCache {
    
    public enum SaveError: Swift.Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
}
