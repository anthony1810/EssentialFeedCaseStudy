//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 9/6/25.
//
import Foundation
import CoreData

extension CoreDataFeedStore {
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.deleteCache(context)
            })
        }
    }
    
    public func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        performAsync { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: items, in: context)
                
                try context.save()
            })
        }
    }
    
    public func retrievalCachedFeed(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            completion(Result {
                if let cache = try ManagedCache.find(in: context) {
                    return (feed: cache.localFeeds, timestamp: cache.timestamp)
                } else {
                    return .none
                }
            })
        }
    }
}
