//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//
import Foundation

public protocol FeedStore {
    typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)
   
    func deleteCachedFeed() throws
    func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date) throws
    func retrievalCachedFeed() throws -> CacheFeed?
}
