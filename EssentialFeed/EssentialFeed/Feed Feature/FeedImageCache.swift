//
//  FeedImageCache.swift
//  EssentialFeed
//
//  Created by Anthony on 20/7/25.
//
import Foundation

public protocol FeedImageCache {
    typealias SaveResult = Swift.Result<Void, Error>
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
