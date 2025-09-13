//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//
import Foundation

public final class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    public typealias LoadResult = Swift.Result<[FeedImage], Error>
    public typealias ValidationResult = Swift.Result<Void, Error>
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        let result = Result { try store.retrievalCachedFeed() }
        
        switch result {
        case .failure(let error):
            completion(.failure(error))
        case .success(.some((let feeds, let timestamp))) where FeedCachePolicy.isCacheValidated(with: timestamp, against: currentDate()):
            completion(.success(feeds.toModel()))
        case .success(.none), .success:
            completion(.success([]))
        }
    }
    
    public func validate(completion: @escaping (ValidationResult) -> Void) {
        let result = Result { try store.retrievalCachedFeed() }
        
        switch result {
        case .failure:
            completion(Result { try store.deleteCachedFeed() } )
        case .success(.some((_, let timestamp))) where FeedCachePolicy.isCacheValidated(with: timestamp, against: currentDate()) == false:
            completion(Result { try store.deleteCachedFeed() })
        case .success(.none), .success:
            completion(.success(()))
        }
    }
    
    private func cacheFeeds(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        let insertionResult = Result { try self.store.insertCachedFeed(items.toLocal(), timestamp: self.currentDate())
        }
        
        switch insertionResult {
        case .success:
            completion(nil)
        case .failure(let error):
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedCache {
    public typealias SaveResult = FeedCache.SaveResult
    
    public func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        let deletionResult = Result { try store.deleteCachedFeed() }
        
        switch deletionResult {
        case .success:
            self.cacheFeeds(items, completion: completion)
        case .failure(let error):
            completion(error)
        }
    }
}

extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}

extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}
