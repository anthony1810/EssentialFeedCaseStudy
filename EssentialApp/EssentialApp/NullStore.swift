//
//  NullStore.swift
//  EssentialApp
//
//  Created by Anthony on 8/9/25.
//
import Foundation
import EssentialFeed

final class NullStore: FeedStore & FeedImageDataStore {
    func deleteCachedFeed() throws {
       
    }
    
    func insertCachedFeed(_ items: [EssentialFeed.LocalFeedImage], timestamp: Date) throws {
        
    }
    
    func retrievalCachedFeed() throws -> CacheFeed? {
        .none
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        .none
    }
    
    func insert(_ data: Data, for url: URL) throws {}
}
