//
//  FeedCacheProtocol.swift
//  EssentialFeed
//
//  Created by Anthony on 23/11/24.
//
import Foundation

public protocol FeedCacheProtocol {
    typealias SaveResult = Error?
    
    func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void)
}

extension FeedCacheProtocol {
    public func saveCacheIgnoreCompletion(feeds: [FeedImage]) {
        save(feeds, completion: { _ in })
    }
}
