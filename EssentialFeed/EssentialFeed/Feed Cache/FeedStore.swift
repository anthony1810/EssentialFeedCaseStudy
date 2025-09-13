//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//
import Foundation

public protocol FeedStore {
    typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)
    
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Swift.Result<CacheFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedFeed() throws
    func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date) throws
    func retrievalCachedFeed() throws -> CacheFeed?
    
    @available(*, deprecated)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    @available(*, deprecated)
    func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    @available(*, deprecated)
    func retrievalCachedFeed(completion: @escaping RetrievalCompletion)
}

public extension FeedStore {
    func deleteCachedFeed() throws {
        let group = DispatchGroup()
        group.enter()
        var result: Swift.Result<Void, Error>!
        
        self.deleteCachedFeed { result = $0; group.leave() }
        
        return try result.get()
    }
    
    func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date) throws {
        let group = DispatchGroup()
        group.enter()
        var result: Swift.Result<Void, Error>!
        
        self.insertCachedFeed(items, timestamp: timestamp) { result = $0; group.leave() }
        
        return try result.get()
    }
    
    func retrievalCachedFeed() throws -> CacheFeed? {
        let group = DispatchGroup()
        group.enter()
        var result: Swift.Result<CacheFeed?, Error>!
        
        self.retrievalCachedFeed { result = $0; group.leave() }
        
        return try result.get()
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {}
    
    func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) { }
    
    func retrievalCachedFeed(completion: @escaping RetrievalCompletion) {}
}
