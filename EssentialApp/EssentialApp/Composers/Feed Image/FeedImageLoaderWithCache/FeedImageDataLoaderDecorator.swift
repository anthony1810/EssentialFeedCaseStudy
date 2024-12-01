//
//  FeedImageDataLoaderDecorator.swift
//  EssentialApp
//
//  Created by Anthony on 23/11/24.
//
import Foundation
import EssentialFeed


public final class FeedImageDataLoaderDecorator: FeedImageDataLoaderProtocol {
    private let decoratee: FeedImageDataLoaderProtocol
    private let cache: FeedImageDataCacheProtocol
    
    public init(decoratee: FeedImageDataLoaderProtocol, cache: FeedImageDataCacheProtocol) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoaderProtocol.Result) -> Void) -> any ImageLoadingDataTaskProtocol {
        
        decoratee.loadImageData(from: url, completion: { [weak self] result in
            completion(result.map { data in
                if let data {
                    self?.saveCacheIgnoreCompletion(data: data, url: url)
                }
                return data
            })
        })
    }
    
    private func saveCacheIgnoreCompletion(data: Data, url: URL) {
        cache.save(data, for: url, completion: { _ in })
    }
}
