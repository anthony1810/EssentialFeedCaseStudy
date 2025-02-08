//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 7/2/25.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    public init() {}
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
       
    }
    
    public func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrievalCachedFeed(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}
