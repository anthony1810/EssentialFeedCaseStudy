//
//  InMemoryFeedStore.swift
//  EssentialApp
//
//  Created by Anthony on 28/11/24.
//
import Foundation
import EssentialFeed

final class InMemoryFeedStore: FeedStoreProtocol {
        
    private(set) var feedCache: Cache?
    private var feedImageDataCache: [URL: Data] = [:]
    
    init(feedCache: Cache? = nil) {
        self.feedCache = feedCache
    }
    
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var expired: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: .found([], Date.distantPast))
    }
    
    static var nonExpired: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: .found([], Date()))
    }
    
    func deleteCache(completion: @escaping DeletionCacheCompletion) {
        feedCache = nil
        completion(nil)
    }
    
    func insertCache(_ items: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCacheCompletion) {
        feedCache = .found(items, timestamp)
        completion(nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
      if let feedCache {
          completion(.success(feedCache))
        } else {
            completion(.success(.empty))
        }
    }
}

extension InMemoryFeedStore: LocalFeedImageStoreProtocol {
    func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(feedImageDataCache[url]))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        feedImageDataCache[url] = data
        completion(.success(data))
    }
}


