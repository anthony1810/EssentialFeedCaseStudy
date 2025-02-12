//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//
import Foundation

public protocol FeedStore {
    typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)
    typealias RetrievalResult = Swift.Result<CacheFeed?, Error>
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrievalCachedFeed(completion: @escaping RetrievalCompletion)
}
