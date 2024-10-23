//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 23/10/24.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
    
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let context: NSManagedObjectContext
    private let container: NSPersistentContainer
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public enum ContextQueue {
        case main
        case background
    }
    
    public init(storeURL: URL, contextQueue: ContextQueue = .background) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = contextQueue == .main ? container.viewContext : container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    public var contextQueue: ContextQueue {
        context == container.viewContext ? .main : .background
    }
}

extension CoreDataFeedStore: FeedStoreProtocol {
    public func deleteCache(completion: @escaping DeletionCacheCompletion) {
        
    }
    
    public func insertCache(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCacheCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
    }
}

