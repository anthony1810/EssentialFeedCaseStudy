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
    @NSManaged var data: Data
    @NSManaged var cache: ManagedCache
    
    static func images(from localFeeds: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        NSOrderedSet(array: localFeeds.map { localFeedImage in
            let managedFeedImage = ManagedFeedImage(context: context)
            managedFeedImage.id = localFeedImage.id
            managedFeedImage.imageDescription = localFeedImage.description
            managedFeedImage.location = localFeedImage.location
            managedFeedImage.url = localFeedImage.url
            managedFeedImage.data = Data()
            
            return managedFeedImage
        })
    }
    
    var local: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, imageURL: url)
    }
}
