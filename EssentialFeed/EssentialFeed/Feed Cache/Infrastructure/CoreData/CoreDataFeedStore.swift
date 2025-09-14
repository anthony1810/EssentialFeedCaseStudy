//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 7/2/25.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        self.container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    deinit {
        cleanUpReferrencesToPersistentStores()
    }
    
    func performAsync(_ action: @escaping (NSManagedObjectContext) -> Void) {
        context.perform { [context] in
            action(context)
        }
    }
    
    func performSync<T>(_ action: @escaping (NSManagedObjectContext) -> Result<T, Error>) throws -> T {
        var result: Result<T, Error>!
        context.performAndWait { [context] in
            result = action(context)
        }
        
        return try result.get()
    }
    
    public func perform(action: @escaping () -> Void) {
        context.perform(action)
    }
    
    private func cleanUpReferrencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
}


