//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 13/10/24.
//
import Foundation

public enum RetrievalResult {
    case empty
    case failure(Error)
    case success([LocalFeedImage], Date)
}

public protocol FeedStore {
    typealias DeletionCacheCompletion = (Error?) -> Void
    typealias InsertionCacheCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCache(completion: @escaping DeletionCacheCompletion)
    func insertCache(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCacheCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
