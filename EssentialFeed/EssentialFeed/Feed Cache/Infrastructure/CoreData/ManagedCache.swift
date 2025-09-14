//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Anthony on 8/2/25.
//
import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    var localFeeds: [LocalFeedImage] {
        feed
            .compactMap { $0 as? ManagedFeedImage }
            .map {
                LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, imageURL: $0.url)
            }
    }
}

extension ManagedCache {
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try deleteCache(context)
        return ManagedCache(context: context)
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        
        let cache = try context.fetch(request).first
        
        return cache
    }
    
    static func deleteCache(_ context: NSManagedObjectContext) throws {
        try find(in: context).map(context.delete).map(context.save)
    }
}
