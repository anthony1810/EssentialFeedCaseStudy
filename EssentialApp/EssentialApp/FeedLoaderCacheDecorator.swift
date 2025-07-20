//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Anthony on 20/7/25.
//
import Foundation
import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: { [weak self] result in
            completion(
                result.map { feed in
                    self?.saveIgnoringResult(feed)
                    return feed
                }
            )
        })
    }
    
    func saveIgnoringResult(_ feed: [FeedImage]) {
        self.cache.save(feed) { _ in }
    }
}
