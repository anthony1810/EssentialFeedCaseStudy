//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//
import Foundation

public protocol FeedStore {
    typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)
   
    typealias DeletionResult = Error?
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Error?
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Swift.Result<CacheFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrievalCachedFeed(completion: @escaping RetrievalCompletion)
}
