//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Anthony on 8/2/25.
//
import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
    
    var local: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, imageURL: url)
    }
}

extension ManagedFeedImage {
    
    static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data? {
        if let cachedDeleteData = context.userInfo[url] as? Data {
            return cachedDeleteData
        }
        
        return try first(with: url, in: context)?.data
    }
    
    static func images(from localFeeds: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        let images = NSOrderedSet(array: localFeeds.map { localFeedImage in
            let managedFeedImage = ManagedFeedImage(context: context)
            managedFeedImage.id = localFeedImage.id
            managedFeedImage.imageDescription = localFeedImage.description
            managedFeedImage.location = localFeedImage.location
            managedFeedImage.url = localFeedImage.url
            managedFeedImage.data = context.userInfo[localFeedImage.url] as? Data
            
            return managedFeedImage
        })
        context.userInfo.removeAllObjects()
        
        return images
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
        let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
    
        managedObjectContext?.userInfo[url] = data
    }
}
