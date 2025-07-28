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
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        cacheFeed = nil
        completion(.success(()))
    }
    
    func insertCachedFeed(_ items: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        cacheFeed = CacheFeed(feed: items, timestamp: timestamp)
        completion(.success(()))
    }
    
    func retrievalCachedFeed(completion: @escaping RetrievalCompletion) {
        completion(.success(cacheFeed))
    }
    
    // MARK: - FeedImageDataStore
    func retrieve(dataForURL url: URL, completion: @escaping (Result<Data?, any Error>) -> Void) {
        completion(.success(feedImageDataCache[url]))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        feedImageDataCache[url] = data
        completion(.success(()))
    }
}
