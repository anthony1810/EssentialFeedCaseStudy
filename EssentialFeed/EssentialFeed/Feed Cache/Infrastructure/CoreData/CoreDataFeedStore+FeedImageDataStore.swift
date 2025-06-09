//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Anthony on 9/6/25.
//
import Foundation
import CoreData

extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataForURL url: URL, completion: @escaping (Result<Data?, any Error>) -> Void) {
        perform { context in
            completion(Result{
                return try ManagedFeedImage.first(with: url, in: context)?.data
            })
        }
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                guard let managedCache = try ManagedFeedImage.first(with: url, in: context)
                else { return }
                
                managedCache.data = data
                try context.save()
            })
        }
    }
}
