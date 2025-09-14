//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Anthony on 9/6/25.
//
import Foundation
import CoreData

extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataForURL url: URL) throws -> Data? {
        try ManagedFeedImage.first(with: url, in: context)?.data
    }
    
    public func insert(_ data: Data, for url: URL) throws {
        try ManagedFeedImage.first(with: url, in: context)
            .map { $0.data = data }
            .map (context.save)
    }
}
