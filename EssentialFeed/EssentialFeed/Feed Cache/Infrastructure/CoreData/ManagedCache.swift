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
        feed.compactMap { $0 as? ManagedFeedImage }
        .map {
            LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, imageURL: $0.url)
        }
    }
}
