//
//  FeedImageLoaderCacheDecorater.swift
//  EssentialApp
//
//  Created by Anthony on 20/7/25.
//
import Foundation
import EssentialFeed

public final class FeedImageLoaderCacheDecorater: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url, completion: { [weak self] result in
            completion(
                result.map { data in
                    self?.saveIgnoringResult(data: data, for: url)
                    return data
                }
            )
        })
    }
    
    private func saveIgnoringResult(data: Data, for url: URL) {
        cache.save(data, for: url) { _ in }
    }
}
