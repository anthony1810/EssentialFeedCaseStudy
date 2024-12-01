//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Anthony on 23/11/24.
//

import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoaderProtocol {
    private let decoratee: FeedLoaderProtocol
    private let cache: FeedCacheProtocol
    
    public init(decoratee: FeedLoaderProtocol, cache: FeedCacheProtocol) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoaderProtocol.Result) -> Void) {
        decoratee.load(completion: { [weak self] result in
            completion(
                result.map { feeds in
                    self?.saveCacheIgnoreCompletion(feeds: feeds)
                    return feeds
                }
            )
        })
    }
    
    private func saveCacheIgnoreCompletion(feeds: [FeedImage]) {
        cache.save(feeds, completion: { _ in })
    }
}
