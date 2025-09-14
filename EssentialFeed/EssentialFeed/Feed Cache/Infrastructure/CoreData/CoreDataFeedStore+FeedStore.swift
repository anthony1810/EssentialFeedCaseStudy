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
        try ManagedCache.deleteCache(context)
    }
    
    public func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date) throws {
        let managedCache = try ManagedCache.newUniqueInstance(in: context)
        managedCache.timestamp = timestamp
        managedCache.feed = ManagedFeedImage.images(from: items, in: context)
        
        try context.save()
    }
    
    public func retrievalCachedFeed() throws -> CacheFeed? {
        try ManagedCache.find(in: context).map {
            CacheFeed(feed: $0.localFeeds, timestamp: $0.timestamp)
        }
    }
}
