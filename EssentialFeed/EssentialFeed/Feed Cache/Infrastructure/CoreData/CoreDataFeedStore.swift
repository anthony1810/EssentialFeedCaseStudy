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
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        self.container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
       
    }
    
    public func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                
                let managedFeeds = items.map {
                    let managedImage = ManagedFeedImage(context: context)
                    managedImage.id = $0.id
                    managedImage.imageDescription = $0.description
                    managedImage.location = $0.location
                    managedImage.data = Data()
                    managedImage.url = $0.url
                    managedImage.cache = managedCache
                    return managedImage
                }
                managedCache.feed = NSOrderedSet(array: managedFeeds)
                
                try context.save()
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrievalCachedFeed(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                    let feeds: [LocalFeedImage] = cache.feed
                        .compactMap { $0 as? ManagedFeedImage }
                        .map {
                            LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, imageURL: $0.url)
                        }
                    
                    completion(.found(feed: feeds, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotfound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let objectModel = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotfound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: objectModel)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}


