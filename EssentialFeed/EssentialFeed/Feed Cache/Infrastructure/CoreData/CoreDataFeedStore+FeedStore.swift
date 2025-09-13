//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 9/6/25.
//
import Foundation
import CoreData

extension CoreDataFeedStore {
    public func deleteCachedFeed() throws {
        try performSync { context in
            Result {
                try ManagedCache.deleteCache(context)
            }
        }
    }
    
    public func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date) throws {
        try performSync { context in
            Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: items, in: context)
                
                try context.save()
            }
        }
    }
    
    public func retrievalCachedFeed() throws -> CacheFeed? {
        try performSync { context in
            Result {
                if let cache = try ManagedCache.find(in: context) {
                    return (feed: cache.localFeeds, timestamp: cache.timestamp)
                } else {
                    return .none
                }
            }
        }
    }
}
