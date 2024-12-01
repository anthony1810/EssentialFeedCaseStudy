//
//  FeedImageDataCacheProtocol.swift
//  EssentialFeed
//
//  Created by Anthony on 23/11/24.
//
import Foundation

public protocol FeedImageDataCacheProtocol {
    typealias SaveResult = Swift.Result<Data, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}

extension FeedImageDataCacheProtocol {
    public func saveCacheIgnoreCompletion(data: Data, url: URL) {
        save(data, for: url, completion: { _ in })
    }
}
