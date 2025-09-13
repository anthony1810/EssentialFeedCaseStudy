//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Anthony on 20/7/25.
//
import Foundation

public protocol FeedCache {
    typealias SaveResult = Error?
    func save(_ items: [FeedImage]) throws
    
    @available(*, deprecated)
    func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void)
}

public extension FeedCache {
    func save(_ items: [FeedImage]) throws {
        let group = DispatchGroup()
        group.enter()
        
        var result: Error?
        save(items, completion: { result = $0; group.leave() })
        
        if let result {
            throw result
        }
    }

    func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        
    }
}
