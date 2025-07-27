//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Anthony on 13/7/25.
//
import EssentialFeed
import Combine

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primaryLoader: FeedLoader
    private let fallbackLoader: FeedLoader
    
    public init(primaryLoader: FeedLoader, fallbackLoader: FeedLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load(completion: { primaryCompletion in
            if case let .success(feeds) = primaryCompletion {
                completion(.success(feeds))
            } else {
                self.fallbackLoader.load(completion: completion)
            }
        })
    }
}
