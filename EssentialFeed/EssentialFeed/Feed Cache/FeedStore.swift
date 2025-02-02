//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//
import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrievalCachedFeed(completion: @escaping RetrievalCompletion)
}
