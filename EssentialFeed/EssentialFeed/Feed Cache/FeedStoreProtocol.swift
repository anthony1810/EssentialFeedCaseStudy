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

public protocol FeedStoreProtocol {
    typealias DeletionCacheCompletion = (Error?) -> Void
    typealias InsertionCacheCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    /// the completion handler can be involked in any thread.
    ///  Clients are responsible to dispatch to approriate, thread if need
    func deleteCache(completion: @escaping DeletionCacheCompletion)
    
    /// the completion handler can be involked in any thread.
    ///  Clients are responsible to dispatch to approriate, thread if need
    func insertCache(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCacheCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
