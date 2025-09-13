//
//  InMemoryStore.swift
//  EssentialApp
//
//  Created by Anthony on 25/7/25.
//
import Foundation
import EssentialFeed

class InMemoryStore: FeedImageDataStore & FeedStore {
    
    private(set) var cacheFeed: CacheFeed?
    private var feedImageDataCache: [URL: Data] = [:]
    
    static var empty: InMemoryStore {
        .init()
    }
    
    static var expiredCacheFeed: InMemoryStore {
        .init(cacheFeed: CacheFeed(
            [],
            Date.distantPast
        ))
    }
    
    static var nonExpiredCacheFeed: InMemoryStore {
        .init(cacheFeed: CacheFeed(
            [],
            Date.now
        ))
    }
    
    init(cacheFeed: CacheFeed? = nil) {
        self.cacheFeed = cacheFeed
    }
    
    // MARK: - FeedStore
    func deleteCachedFeed() throws {
        cacheFeed = nil
    }
    
    func insertCachedFeed(_ items: [EssentialFeed.LocalFeedImage], timestamp: Date) throws {
        cacheFeed = CacheFeed(feed: items, timestamp: timestamp)
    }
    
    func retrievalCachedFeed() throws -> CacheFeed? {
        cacheFeed
    }
    
    // MARK: - FeedImageDataStore
    func retrieve(dataForURL url: URL) throws -> Data? {
        feedImageDataCache[url]
    }
    
    func insert(_ data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }
}
