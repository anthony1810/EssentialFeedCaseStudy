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
    
    public func load() throws -> [FeedImage] {
        
        if let (feed, timestamp) = try store.retrievalCachedFeed(),
           FeedCachePolicy.isCacheValidated(with: timestamp, against: currentDate()) {
            return feed.toModel()
        }
        
        return []
    }
    
    public func validate() throws {
        do {
            guard let cacheFeed = try store.retrievalCachedFeed() else {
                return
            }
            
            if FeedCachePolicy.isCacheValidated(with: cacheFeed.timestamp, against: currentDate()) == false {
                try store.deleteCachedFeed()
            }
        } catch {
            try store.deleteCachedFeed()
        }
    }
}

extension LocalFeedLoader: FeedCache {
    public typealias SaveResult = FeedCache.SaveResult
    
    public func save(_ items: [FeedImage]) throws {
        try store.deleteCachedFeed()
        try self.store.insertCachedFeed(items.toLocal(), timestamp: self.currentDate())
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
