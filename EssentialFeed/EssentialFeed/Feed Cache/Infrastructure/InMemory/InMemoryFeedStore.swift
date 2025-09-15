//
//  InMemoryFeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 14/9/25.
//

import Foundation

public class InMemoryFeedStore {
    private var feedCache: CacheFeed?
    private var feedImageDataCache = NSCache<NSURL, NSData>()
    
    public init() {}
}

extension InMemoryFeedStore: FeedStore {
    public func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date) throws {
        feedCache = CacheFeed(feed: items, timestamp: timestamp)
    }
    
    public func retrievalCachedFeed() throws -> CacheFeed? {
        feedCache
    }
    
    public func deleteCachedFeed() throws {
        feedCache = nil
    }
}

extension InMemoryFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL) throws {
        feedImageDataCache.setObject(data as NSData, forKey: url as NSURL)
    }
    
    public func retrieve(dataForURL url: URL) throws -> Data? {
        feedImageDataCache.object(forKey: url as NSURL) as Data?
    }
}
