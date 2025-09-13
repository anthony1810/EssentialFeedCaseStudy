//
//  NullStore.swift
//  EssentialApp
//
//  Created by Anthony on 8/9/25.
//
import Foundation
import EssentialFeed

final class NullStore: FeedStore & FeedImageDataStore {
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insertCachedFeed(_ items: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrievalCachedFeed(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        .none
    }
    
    func insert(_ data: Data, for url: URL) throws {}
}
