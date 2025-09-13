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
    
    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let data = try store.retrieve(dataForURL: url) {
                return data
            }
        } catch {
            throw LocalFeedImageDataLoader.LoadError.failed
        }
        
        throw LocalFeedImageDataLoader.LoadError.notFound
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
