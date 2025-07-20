//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Anthony on 20/7/25.
//
import Foundation

public protocol FeedCache {
    typealias SaveResult = Error?
    func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
